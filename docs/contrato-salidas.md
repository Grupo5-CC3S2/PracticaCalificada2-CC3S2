# Contrato de salidas

Este archivo es un listado de los artefactos generados, su formato y cómo validarlos. 

## Archivos generados

### Peticiones al servicio eco HTTP

`out/http_local_post_traza.txt`
- Contiene la salida de `curl -v "http://${HOST}:${PORT}/salud" -s -o /dev/null`. `HOST` y `PORT`, por defecto, son `localhost` y `8080`.
- Incluye request line y headers enviados.
- Se puede comprobar que aparece > GET /salud HTTP/1.1 en el request y 200 OK en la terminal del servidor, y en las cabeceras (el archivo).

### Peticiones a un servicio público HTTPS

`out/https_example.org_traza.txt`
- Contiene la salida de `curl -v "https://${TARGET_HOST}" -s -o /dev/null`. `TARGET_HOST` es el host público de prueba que se usa.
- Incluye detalles del handshake TLS y las cabeceras de la petición.
- Debe contener líneas como * TLSv1.3 handshake.

`openssl_example.org.txt`
- Contiene la salida de `openssl s_client -connect "${TARGET_HOST}:${TARGET_PORT}" -msg -showcerts`.
- Incluye detalles del handshake TLS completo, certificados presentados y parámetros de cifrado (como el cipher suite).

### Traza de sockets

`out/ss_trace.txt`
- Contiene la salida de `ss -tanp` en el host local durante la ejecución del servidor.
- Permite verificar los sockets abiertos y procesos asociados (PID/comm). Se filtran solo los que abren los comandos ejecutados en `handshake_analizer.sh` (curl, openssl)

## Artefactos Generados por Make

- `make build`
  - `out/http_local_post_traza.txt`: traza http local
  - `out/https_example_org_traza.txt`: traza https a example org
  - `out/openssl_example_org.txt`: inspeccion de certificado de example org
  - `out/ss_trace.txt`: traza de sockets con ss

- `make release`
  - `out/release/`: directorio con el codigo fuente y documentacion para el release
  - `out/release/.release_done`: stamp file para indicar que el release esta listo

- `make pack`
  - `dist/proyecto-vX.X.X.tar.gz`: paquete tar con el proyecto

- `make run-dns`
  - `out/dns-analysis-*.txt`: resultado del analisis dns

- `make systemd-setup`
  - `~/.config/systemd/user/servicio-eco.service`: archivo de unidad de systemd configurado

- `make systemd-install`
  - `~/.config/systemd/user/servicio-eco.service`: archivo de unidad de systemd
  - `~/.config/systemd/user/servicio-eco.env`: archivo de entorno para el servicio
