#!/usr/bin/env bats

setup() {
    # Configurar entorno de prueba
    export OUT_DIR="./out/test_systemd"
    mkdir -p "$OUT_DIR"
}

teardown() {
    rm -rf "$OUT_DIR"
}

@test "Servicio systemd puede iniciarse en modo prueba" {
    skip "Requiere systemd real para pruebas completas"
    # Esta prueba seria para entorno real con systemd
}

@test "Archivo de entorno systemd tiene formato correcto" {
    run test -f "systemd/servicio-eco.env.template"
    [ "$status" -eq 0 ]
    
    run grep "DNS_SERVER" "systemd/servicio-eco.env.template"
    [ "$status" -eq 0 ]
}

@test "Unidad systemd tiene dependencias correctas" {
    run grep "After=network.target" "systemd/servicio-eco.service"
    [ "$status" -eq 0 ]
    
    run grep "Wants=network-online.target" "systemd/servicio-eco.service"
    [ "$status" -eq 0 ]
}

@test "WorkingDirectory del servicio usa ruta relativa" {
    run grep "WorkingDirectory=." "systemd/servicio-eco.service"
    [ "$status" -eq 0 ]
}