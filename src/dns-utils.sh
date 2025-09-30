#!/usr/bin/env bash
set -euo pipefail

# Variables de entorno
DNS_SERVER="${DNS_SERVER:-}" # vacio para usar localmente
DOMINIO="${DOMINIO:-localhost}"

# Resolucion de registro A
resolver_a() {
    local dominio="$1"
    # Mensaje de debug solo si VERBOSE esta activo
    [[ "${VERBOSE:-}" == "1" ]] && echo "Resolviendo A para: $dominio" >&2
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
    [[ "${VERBOSE:-}" == "1" ]] && echo "Resolviendo CNAME para: $dominio" >&2
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

# Funcion principal - Solo analisis DNS
analizar_dns() {
    local dominio="$1"
    echo "=== Analisis DNS para: $dominio ==="
    echo "Registro A: $(VERBOSE=1 resolver_a "$dominio")"
    echo "Registro CNAME: $(VERBOSE=1 resolver_cname "$dominio")"
    echo "TTL (A): $(obtener_ttl "$dominio" A) segundos"
    echo "=== Fin analisis ==="
}

# Analisis DNS avanzado con pipelines Unix
analizar_dns_avanzado() {
    local dominio="$1"
    local output_file="${2:-./out/dns_avanzado_$(date +%Y%m%d_%H%M%S).csv}"
    
    mkdir -p "$(dirname "$output_file")"
    
    echo "Ejecutando analisis DNS avanzado para: $dominio"
    
    # Pipeline complejo: obtener todos los registros y procesar
    local dig_output
    if [[ -z "$DNS_SERVER" ]]; then
        dig_output=$(dig +noall +answer +additional "$dominio" ANY 2>/dev/null || true)
    else
        dig_output=$(dig +noall +answer +additional "$dominio" ANY @"$DNS_SERVER" 2>/dev/null || true)
    fi
    
    # Header CSV
    echo "timestamp,dominio,tipo_registro,valor,ttl,server_dns" > "$output_file"
    
    # Procesar con awk y grep
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local dns_server_used="${DNS_SERVER:-system}"
    
    printf "%s\n" "$dig_output" | grep -v "^;" | awk -v dom="$dominio" -v ts="$timestamp" -v ds="$dns_server_used" '
    {
        if (NF >= 4) {
            # Extraer nombre, ttl, clase, tipo y valor
            name = $1
            ttl = $2
            class = $3
            type = $4
            value = ""
            for (i=5; i<=NF; i++) value = value (i>5 ? " " : "") $i
            
            # Limpiar punto final del nombre
            sub(/\.$/, "", name)
            
            # Solo incluir si el nombre coincide con el dominio
            if (name == dom) {
                print ts "," dom "," type "," "\"" value "\"" "," ttl "," ds
            }
        }
    }' >> "$output_file"
    
    # Estadisticas adicionales con pipelines
    local total_registros=$(tail -n +2 "$output_file" | wc -l)
    local tipos_unicos=$(tail -n +2 "$output_file" | cut -d, -f3 | sort | uniq | tr '\n' ' ')
    
    echo "=== RESUMEN ANALISIS AVANZADO ==="
    echo "Dominio: $dominio"
    echo "Total registros: $total_registros"
    echo "Tipos encontrados: $tipos_unicos"
    echo "Archivo CSV: $output_file"
    echo "================================="
}

# Funcion para modo servicio (systemd)
ejecutar_como_servicio() {
    local dominio="${DOMINIO:-localhost}"
    local log_file="./out/dns_service_$(date +%Y%m%d).log"
    
    mkdir -p "$(dirname "$log_file")"
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Iniciando servicio DNS" >> "$log_file"
    
    while true; do
        local resultado
        resultado=$(analizar_dns "$dominio")
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $resultado" >> "$log_file"
        sleep 60  # Ejecutar cada minuto
    done
}
