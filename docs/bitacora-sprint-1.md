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

## Estudiante 2 (Jhon Cruz)