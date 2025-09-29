#!/usr/bin/env bash
set -euo pipefail

# Variables de entorno con defaults
PORT="${PORT:-8080}"
HOST="${HOST:-127.0.0.1}"

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
pipe=""

# Se elimina el archivo de pipe
cleanup() {
  if [ -n "${pipe:-}" ] && [ -e "$pipe" ]; then
    rm -f "$pipe"
  fi
}

trap cleanup EXIT SIGINT SIGTERM

echo "Servidor escuchando en http://${HOST}:${PORT} ..." >&2

while true; do
  # Se obtiene un nombre temporal en tmp/ y se usa para definir el pipe con mkfifo
  pipe=$(mktemp -u /tmp/server_pipe.XXXXXX)
  mkfifo "$pipe" || { echo "No se pudo crear FIFO" >&2; exit 1; }

  # Servidor usando netcat
  nc -l -p "$PORT" <"$pipe" | (
    read -r request_line || exit 1

    # Ignora los headers hasta la línea en blanco
    while read -r line; do
      line="${line%%$'\r'}"
      [ -z "$line" ] && break
    done

    method="$(echo "$request_line" | awk '{print $1}')"
    path="$(echo "$request_line" | awk '{print $2}')"
    version="$(echo "$request_line" | awk '{print $3}' | tr -d '\r')"

    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] $request_line" >&2

    # Validación de petición (métodos soportados, mala petición, rutas permitidas)
    case "$method" in
      "GET"|"HEAD")
        case "$path" in
          "/salud")
            status="200 OK"
            body="Servicio operativo"
            ;;
          *) 
            status="404 Not Found"
            body="Error 404: Resource not found"
            ;;
        esac
        ;;
      "")
        status="400 Bad Request"
        body="Error 400: Bad Request - Missing HTTP method"
        ;;
      *)
        status="405 Method Not Allowed"
        body="Error 405: Method Not Allowed - Supported: GET, HEAD"
        ;;
    esac

    # Cabeceras HTTP
    response_headers=""
    response_headers+="$version $status"$'\r\n'
    response_headers+="Content-Type: text/plain"$'\r\n'
    response_headers+="Server: BashHTTP/1.0"$'\r\n'
    response_headers+="Date: $(date -u '+%a, %d %b %Y %H:%M:%S GMT')"$'\r\n'
    response_headers+="Connection: close"$'\r\n'

    # Enviar respuesta
    echo -e "$response_headers"
    echo -e "$body"

    echo "[$timestamp] Response: $status (Method: $method, Path: $path)" >&2
  ) >"$pipe"

  # Se elimina el nombre aleatorio del pipe, para usar otro para la siguiente petición
  rm -f "$pipe"
  pipe=""
done
