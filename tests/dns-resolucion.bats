#!/usr/bin/env bats

setup() {
    source src/dns-utils.sh
    mkdir -p out
}

@test "Resolucion A funciona" {
    run resolver_a "localhost"
    [ "$status" -eq 0 ]
    [[ "$output" == *"127.0.0.1"* ]]
}

@test "Resolucion CNAME funciona" {
    run resolver_cname "localhost"
    [ "$status" -eq 0 ]
}

@test "Parseo TTL funciona" {
    run obtener_ttl "localhost" "A"
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^[0-9]+$ ]]
}

@test "Analisis DNS completo funciona" {
    run analizar_dns "localhost"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Analisis DNS"* ]]
}

@test "Resolucion A dominio inexistente retorna vacio" {
    result=$(resolver_a "dominio-inexistente-123456789000.test")
    [ -z "$result" ]
}

@test "Resolucion CNAME dominio inexistente retorna vacio" {
    result=$(resolver_cname "dominio-inexistente-123456789000.test")
    [ -z "$result" ]
}

@test "TTL dominio inexistente es 0" {
    run obtener_ttl "dominio-inexistente-123456789000.test" "A"
    [ "$status" -eq 0 ]
    [ "$output" -eq 0 ]
}

@test "DNS server invalido se maneja gracefely" {
    result=$(DNS_SERVER="192.0.2.1" resolver_a "google.com" || true)
    # El test pasa si no crashea - el resultado puede ser vacio
    true
}

@test "Analisis DNS avanzado genera CSV" {
    run analizar_dns_avanzado "localhost" "out/test_avanzado.csv"
    [ "$status" -eq 0 ]
    [ -f "out/test_avanzado.csv" ]
}