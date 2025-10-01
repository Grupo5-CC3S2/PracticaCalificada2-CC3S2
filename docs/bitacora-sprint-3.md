## Estudiante 1 (Daren Herrera)

(Pendiente)

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