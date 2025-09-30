#!/usr/bin/env bash
set -euo pipefail

HOSTS="${HOSTS:-localhost}"
PORTS="${PORTS:-80 443 8080}"
INTERFACE="${INTERFACE:-eth0}"
OUTPUT_DIR="${OUTPUT_DIR:-./out}"

verificar_conectividad() {
    local host="$1"
    echo "=== Verificando conectividad a $host ==="
    
    if [[ "$host" == "localhost" ]]; then
        if ping -c 1 -W 1 127.0.0.1 >/dev/null 2>&1; then
            echo "Localhost accesible via 127.0.0.1"
        else
            echo "No se pudo hacer ping a 127.0.0.1"
        fi
    else
        if ip route get "$host" >/dev/null 2>&1; then
            echo "Ruta disponible a $host"
        else
            echo "No se puede verificar ruta a $host"
        fi
    fi
    echo
}

analizar_sockets() {
    local output_file="$OUTPUT_DIR/sockets_$(date +%Y%m%d_%H%M%S).txt"
    
    echo "=== Analisis de sockets ==="
    mkdir -p "$(dirname "$output_file")"
    
    {
        echo "=== SOCKETS ESCUCHANDO ==="
        ss -tulpn | grep LISTEN | awk '{print $1 "\t" $2 "\t" $5 "\t" $7}' | sort
        echo
        echo "=== CONEXIONES ESTABLECIDAS ==="
        ss -tupn | grep ESTAB | awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $6}' | sort
    } > "$output_file"
    
    cat "$output_file"
    echo "Resultados guardados en: $output_file"
}

probar_puertos() {
    local host="$1"
    local ports=($2)
    local output_file="$OUTPUT_DIR/ports_${host}_$(date +%Y%m%d_%H%M%S).csv"
    
    echo "=== Probando puertos en $host ==="
    mkdir -p "$(dirname "$output_file")"
    
    echo "host,port,status,service" > "$output_file"
    
    for port in "${ports[@]}"; do
        local status="closed"
        local service=""
        
        if nc -z -w 3 "$host" "$port" 2>/dev/null; then
            status="open"
            service=$(getent services "$port" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
        fi
        
        echo "$host,$port,$status,$service" >> "$output_file"
        echo "Puerto $port: $status ($service)"
    done
    
    echo "Resultados guardados en: $output_file"
}

monitoreo_completo() {
    local hosts=($HOSTS)
    local ports=($PORTS)
    
    echo "Iniciando monitoreo de red..."
    echo "Hosts: ${hosts[*]}"
    echo "Puertos: ${ports[*]}"
    echo
    
    analizar_sockets
    
    for host in "${hosts[@]}"; do
        verificar_conectividad "$host"
        probar_puertos "$host" "${ports[*]}"
        echo
    done
    
    echo "Monitoreo completado"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    monitoreo_completo
fi