## Estudiante 1 (Daren Herrera)

- Para poder ejecutar todo lo implementado, primero se tiene que levantar el servicio HTTP con:

    ```bash
    make run
    ```

    Salida en la terminal (con las variables de entorno por defecto):

    ```console
    Servidor escuchando en http://localhost:8080 ...
    ```

    > Se pueden cambiar. Las variables son: PORT (8080) y HOST (localhost o 127.0.0.1)

- Usé de comandos como `curl -v` y `open ssl_client` para poder ver más detalles de las conexiones HTTP y HTTPS. Todo esto lo implementé en el script `handshake_analizer.sh` el cual se puede ejecutar con:
    
    ```bash
    make build
    ```

    Esto generará algunos archivos donde se almacenarán los resultados y trazas.

    ```console
    Ejecutando analizador de conexión (HTTP/HTTPS)...
    Capturando traza HTTP local (servicio local - GET /salud)...
    Capturando traza HTTPS (servicio público example.org - GET)...
    Ejecutando openssl s_client para inspeccionar certificado...
    Archivos generados en /home/yo/PracticaCalificada2-CC3S2/out:
    http_local_post_traza.txt
    https_example.org_traza.txt
    openssl_example.org.txt
    ss_trace.txt
    ```
- Para los tests, implementé tanto positivos, como negativos en `test-http-service.bats`. Este se puede ejecutar con:
    
    ```bash
    make test-http
    ```

    Salida esperada:

    ```console
    ✓ POST /eco devuelve el mismo body (positivo)
    ✓ GET /salud devuelve 200 (positivo)
    ✓ GET recurso inexistente devuelve 404 (negativo)
    ✓ Host inválido falla (negativo)
    ✓ Conexión a puerto inválido (negativo)
    ``` 

- También actualicé el `Makefile` con nuevos targets (se juntaron algunos) y nuevas recetas.

**Decisiones tomadas**

- Decidí usar `-msg` para `openssl` (en el script `handshake_analizer.sh`) para poder imprimir los mensajes binarios del handshake y hacerlo más detallado.
- Usé `ss` dentro de un bucle, buscando palabras claves y cada cierto tiempo, durante todo el script de `handshake_analizer.sh` para ver que sockets se abren al ejecutar los comandos `curl` y `openssl`. El subshell que implemnta todo esto, desactiva temporalmente la salida del script por algún error, para que al final se pueda "matar" el proceso sin tener algún error.

## Estudiante 2 (Jhon Cruz) - Rama: `feature/dns-systemd`

Este sprint se centró en la maduración de los scripts, la creación de herramientas de monitoreo y la mejora de la integración con systemd.

### 1. Análisis DNS Avanzado y Modo Servicio (`src/dns-utils.sh`)

Se extendieron las capacidades del script de DNS con funciones más potentes:

- **`analizar_dns_avanzado(dominio, archivo_salida)`**: Esta función implementa un pipeline complejo para un análisis exhaustivo.
    - Utiliza `dig ANY` para obtener todos los registros DNS de un dominio.
    - Procesa la salida con `grep` y `awk` para transformar los datos en un formato estructurado CSV, incluyendo timestamp, tipo de registro, valor y TTL.
    - Genera un archivo de salida con los resultados y calcula estadísticas adicionales como el número total de registros y los tipos únicos encontrados (`wc`, `cut`, `sort`, `uniq`).
- **`ejecutar_como_servicio()`**: Se añadió una función que opera en un bucle infinito (`while true`), ejecutando el análisis DNS a intervalos regulares (`sleep 60`). Esta función está diseñada para ser gestionada por systemd, enviando su salida directamente al journal.

### 2. Script de Monitoreo de Red (`src/monitor-red.sh`)

Se creó un nuevo script para realizar un chequeo general del estado de la red, compuesto por varias funciones:

- **`verificar_conectividad(host)`**: Comprueba la alcanzabilidad de un host usando `ping` para `localhost` y `ip route get` para hosts remotos.
- **`analizar_sockets()`**: Emplea `ss` junto con `grep`, `awk` y `sort` para generar un reporte de los sockets en estado `LISTEN` y `ESTAB`, guardando el resultado en `out/`.
- **`probar_puertos(host, puertos)`**: Itera sobre una lista de puertos y utiliza `nc -z` para verificar si están abiertos en un host específico. Los resultados (open/closed) se guardan en un archivo CSV.

### 3. Mejora de la Unidad Systemd (`systemd/servicio-eco.service`)

Se robusteció la unidad de servicio para asegurar un arranque fiable:

- Se añadieron las directivas `After=network.target` y `Wants=network-online.target`. Esto garantiza que el servicio solo se inicie después de que la red esté completamente configurada y en línea, evitando errores de conectividad al arrancar.

### 4. Extensión de Pruebas Bats (`tests/systemd-validation.bats`)

Se creó una nueva suite de pruebas para validar la configuración de systemd:

- Se verifica que el archivo de la unidad de servicio contenga las dependencias de red correctas (`After=` y `Wants=`).
- Se comprueba la existencia del archivo de configuración de entorno (`.env.template`), asegurando que la plantilla para las variables de entorno esté disponible.
