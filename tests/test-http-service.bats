#!/usr/bin/env bats

setup() {
  export PORT="${PORT:-8080}"
  export HOST="${HOST:-localhost}"
}

@test "POST /eco devuelve el mismo body (positivo)" {
  run curl -s -X POST "http://${HOST}:${PORT}/eco" -d "hola"
  [ "$status" -eq 0 ]
  [ "$output" = "hola" ]
}

@test "GET /salud devuelve 200 (positivo)" {
  code=$(curl -s -o /dev/null -w "%{http_code}" "http://${HOST}:${PORT}/salud")
  [ "$code" -eq 200 ]
}

@test "GET recurso inexistente devuelve 404 (negativo)" {
  code=$(curl -s -o /dev/null -w "%{http_code}" "http://${HOST}:${PORT}/no-existe")
  [ "$code" -eq 404 ]
}

@test "Host inválido falla (negativo)" {
  run curl --max-time 2 -s "http://noexiste.local:${PORT}/eco"
  [ "$status" -ne 0 ]
}

@test "Conexión a puerto inválido (negativo)" {
  run curl --max-time 2 -s "http://${HOST}:9999/eco"
  [ "$status" -ne 0 ]
}
