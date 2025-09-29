#!/usr/bin/env bash
set -euo pipefail

# Variables de entorno
DNS_SERVER="${DNS_SERVER:-}" # vacio para usar localmente
DOMINIO="${DOMINIO:-localhost}"

# Resolución de registro A
resolver_a() {
    local dominio="$1"
    echo "Resolviendo A para: $dominio" >&2
    local result
    if [[ -z "$DNS_SERVER" ]]; then                                               # su DNS_SERVER esta vacio usa resolucion por defecto
        result=$(dig +short +nocmd -t A "$dominio" 2>/dev/null | head -1 || true) # toma solo la ip
    else
        result=$(dig +short +nocmd -t A "$dominio" @"$DNS_SERVER" 2>/dev/null | head -1 || true)
    fi
    echo "$result" # muestra el resultado
}

# Resolucion de registro CNAME (lo mismo pero con los alias)
resolver_cname() {
    local dominio="$1"
    echo "Resolviendo CNAME para: $dominio" >&2
    local result
    if [[ -z "$DNS_SERVER" ]]; then
        result=$(dig +short +nocmd -t CNAME "$dominio" 2>/dev/null | head -1 || true)
    else
        result=$(dig +short +nocmd -t CNAME "$dominio" @"$DNS_SERVER" 2>/dev/null | head -1 || true)
    fi
    echo "$result"
}

# Parseo de TTL
obtener_ttl() {
    local dominio="$1"
    local tipo_registro="${2:-A}"
    local ttl_line ttl # ttl guarda respuesta completa dig, ttl solo el segndo argumento

    if [[ -z "$DNS_SERVER" ]]; then                                                       # -z -> string long 0 (es decir vacio)
        ttl_line=$(dig +noall +answer -t "$tipo_registro" "$dominio" 2>/dev/null || true) # noall muestra la respuesta ttl
    else
        ttl_line=$(dig +noall +answer -t "$tipo_registro" "$dominio" @"$DNS_SERVER" 2>/dev/null || true)
    fi

    # Buscar la primera linea de respuesta que tenga el host (con o sin punto final)
    ttl=$(printf "%s\n" "$ttl_line" | awk -v d="$dominio" '{  # verifica que dominio coincida con $1
        host=$1
        sub(/\.$/,"",host)            # quitar posible punto final
        if (host==d) {
            for(i=2;i<=NF;i++){ # si existe coincidencia extrae el segundo valor
                if ($i ~ /^[0-9]+$/) { print $i; exit }
            }
        }
    }' | head -n1 || true)

    if [[ -z "$ttl" ]]; then
        echo "0"
    else
        echo "$ttl"
    fi
}

# Función principal - Solo análisis DNS
analizar_dns() {
    local dominio="$1"

    echo "=== Analisis DNS para: $dominio ==="
    echo "Registro A: $(resolver_a "$dominio")"
    echo "Registro CNAME: $(resolver_cname "$dominio")"
    echo "TTL (A): $(obtener_ttl "$dominio" A) segundos"
    echo "=== Fin análisis ==="
}

# Ejecucutar
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    analizar_dns "${DOMINIO}"
fi
