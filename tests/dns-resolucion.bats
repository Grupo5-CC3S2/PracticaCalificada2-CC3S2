#!/usr/bin/env bats

setup() {
    source src/dns-utils.sh
}

@test "Resolucion A funciona" {
    run resolver_a "localhost"
    [ "$status" -eq 0 ]
    [[ "$output" == *"127.0.0.1"* ]]
}

@test "Resolucion CNAME funciona" {
    run resolver_cname "localhost"
    [ "$status" -eq 0 ]
    # Puede estar vacío, no debe fallar
}

@test "Parseo TTL funciona" {
    run obtener_ttl "localhost" "A"
    [ "$status" -eq 0 ]
    # Solo verifica que es un número (0 es válido)
    [[ "$output" =~ ^[0-9]+$ ]]
}

@test "Analisis DNS completo funciona" {
    run analizar_dns "localhost"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Análisis DNS"* ]]
}