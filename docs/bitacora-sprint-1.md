## Estudiante 1 (Daren Herrera)

- Para levantar el servicio HTTP de eco:

    ```bash
    make run
    # o
    bash src/servicio_http_eco.sh
    ```

    Salida en la terminal (con las variables de entorno por defecto):

    ```console
    Servidor escuchando en http://localhost:8080 ...
    ```

    > Se pueden cambiar. Las variables son: PORT (8080) y HOST (localhost o 127.0.0.1)

- Para hacer pruebas con el endpoint inicial de `/salud` (con las variables de entorno por defecto):

    ```bash
    curl http://localhost:8080/salud
    ```

    En la terminal del cliente:

    ```console
    Servicio operativo
    ```

    En la terminal del servidor:

    ```bash
    [2025-09-28 12:11:00] GET /salud HTTP/1.1
    [2025-09-28 12:11:00] Response: 200 OK (Method: GET, Path: /salud)
    ```

    También podemos agregar opciones como `-I` (el método `HEAD` está soportado). Si hacemos una petición con un método distinto a ambos, a una ruta no existente (diferente de `/salud`) se devolverán los errores respectivos.

- Sobre el `Makefile`, se implementó:
    - `pack` empaqueta el proyecto (sólo los script, documentación y makefile). Implementa caché incremental.
    - `run` levanta el servicio eco HTTP.
    - `clean` limpia `out/` y `dist/`
    - Variables de entorno:
        - `HOST`: Donde se hostea el servidor (`localhost` por defecto)
        - `PORT`: Puerto del servidor donde está el servicio (8080 por defecto)
        - `RELEASE`: Versión del proyecto (para el empaquetado, `v0.1.0` por defecto)

- Por ahora, aún no se genera nada en `out/` (se tiene planeado hacerlo con `make build`).

## Estudiante 2 (Jhon Cruz) - Rama: `feature/dns-systemd`

En este sprint, el enfoque fue construir la base para el análisis de DNS y la integración con systemd.

### 1. Utilidades DNS (`src/dns-utils.sh`)

Se creó un script robusto para realizar consultas DNS, que incluye las siguientes funciones clave:

- **`resolver_a(dominio)`**: Resuelve el registro A de un dominio. Utiliza `dig +short` para obtener la dirección IP de forma limpia. Es flexible, permitiendo especificar un servidor DNS a través de la variable de entorno `DNS_SERVER`.
- **`resolver_cname(dominio)`**: Similar a la anterior, pero para registros CNAME, encontrando los alias del dominio.
- **`obtener_ttl(dominio, tipo_registro)`**: Extrae el Time-To-Live (TTL) de un registro. Esta función es más compleja, ya que utiliza `dig +noall +answer` y un pipeline de `awk` para parsear la respuesta y extraer el valor numérico del TTL, manejando casos donde no se encuentra.
- **`analizar_dns(dominio)`**: Función principal que orquesta las llamadas a las otras funciones para generar un reporte consolidado del análisis DNS de un dominio.

### 2. Pruebas con Bats (`tests/dns-resolucion.bats`)

Para asegurar la calidad y el correcto funcionamiento del script de DNS, se implementó una suite de pruebas inicial utilizando Bats:

- **Pruebas Positivas**: Se valida que `resolver_a`, `resolver_cname` y `obtener_ttl` funcionen correctamente para un dominio conocido como `localhost`.
- **Pruebas Negativas**: Se crearon casos de prueba para manejar fallos de manera controlada. Por ejemplo, se verifica que al consultar un dominio inexistente se retorne un resultado vacío y que el TTL sea 0. También se prueba que el script no falle si se le pasa un servidor DNS inválido.

### 3. Unidad de Systemd (`systemd/servicio-eco.service`)

Se sentaron las bases para que los scripts se puedan ejecutar como un servicio del sistema. Se creó un archivo de unidad (`.service`) básico que define cómo `systemd` debe gestionar el script. En esta etapa, es una configuración inicial que será extendida en sprints posteriores.

### 4. Documentación

Se inició la documentación del proyecto, creando el `contrato-salidas.md` para definir los artefactos generados y se comenzó a registrar el progreso en esta bitácora.
