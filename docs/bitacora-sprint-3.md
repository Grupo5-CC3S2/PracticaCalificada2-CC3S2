## Estudiante 1 (Daren Herrera)
Mejoré el servidor HTTP servicio_http_eco.sh:
- Para el caso particular de POST /eco con cuerpo vacío, se devuelve 200 OK con cuerpo vacío (en lugar de un error).

Implementé pruebas adicionales en tests/test-http-service.bats, que incluyen tanto casos positivos como negativos. Se ejecutan con:

    ```bash
    make test-http
    ```

    Salida esperada:

    ✓ POST /eco devuelve el mismo body (positivo)
    ✓ POST /eco con cuerpo vacío devuelve 200 y cuerpo vacío (positivo)
    ✓ GET /salud devuelve 200 (positivo)
    ✓ GET recurso inexistente devuelve 404 (negativo)
    ✓ Host inválido falla (negativo)
    ✓ Conexión a puerto inválido (negativo)
    ✓ Método no permitido devuelve 405 (negativo)

También actualicé el Makefile:
- Se agregó el target release para preparar los archivos para su empaquetado
- Se reorganizó el target pack para que dependa del contenido de release y genere un .tar.gz dentro de dist/.

**Decisiones tomadas**
- Elegí devolver 200 OK con cuerpo vacío en POST /eco cuando no hay contenido
- Opté por separar release y pack en el Makefile, para revisar primero el contenido preparado antes de empaquetarlo. Esto es el reemplazo del flujo build/release/run, debido a que el sistema no usa artefactos intermedios.

## Estudiante 2 (Jhon Cruz)