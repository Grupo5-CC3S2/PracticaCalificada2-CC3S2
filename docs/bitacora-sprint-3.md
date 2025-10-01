## Estudiante 1 (Daren Herrera)
Mejoré el servidor HTTP `servicio_http_eco.sh`:
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

## Estudiante 2 (Jhon Cruz) - Rama: `feature/dns-systemd`

El objetivo de este sprint fue completar la integración con systemd, enfocándose en la observabilidad y el monitoreo de logs del servicio.

### 1. Implementación de Logging con `journalctl`

Una vez que el script `dns-utils.sh` se ejecuta como un servicio gestionado por systemd (usando la función `ejecutar_como_servicio`), toda su salida estándar y de error es capturada automáticamente por el `journal` de systemd. Para visualizar y analizar estos logs, se ha integrado el uso de `journalctl`.

Se crearon targets específicos en el `Makefile` para facilitar el acceso a los logs:

- **`make systemd-logs`**:
    - Ejecuta el comando `journalctl --user -u servicio-eco -f`.
    - El flag `-u servicio-eco` filtra los logs para mostrar únicamente las entradas correspondientes a nuestra unidad de servicio.
    - El flag `-f` (follow) permite ver los logs en tiempo real, mostrando las nuevas entradas a medida que el servicio las genera. Esto es fundamental para el monitoreo en vivo y la depuración.

- **`make systemd-test`**:
    - Dentro de la secuencia de prueba, se utiliza `journalctl --user -u servicio-eco -n 20 --no-pager`.
    - El flag `-n 20` limita la salida a las últimas 20 líneas, lo cual es útil para obtener un resumen rápido del estado más reciente del servicio sin abrumar al usuario con logs históricos.
    - `--no-pager` asegura que la salida se imprima directamente en la consola, facilitando su uso en scripts automáticos.

Esta implementación proporciona una forma robusta y estándar en la industria para la gestión de logs, permitiendo un monitoreo y diagnóstico eficientes del servicio DNS.
