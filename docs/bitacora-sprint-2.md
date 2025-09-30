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

## Estudiante 2 (Jhon Cruz)