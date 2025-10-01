# Proyecto de Servidor HTTP Básico y Herramientas de Red en Bash

## Integrantes:

- Daren Herrera Romo (scptx0)
- Jhon Cruz Tairo (JECT-02)
- Anthony Carlos Ramón (AnthonyCar243)

## Descripción del Proyecto

Este proyecto consiste en un conjunto de scripts de Bash que proporcionan un servidor web HTTP básico y varias herramientas de línea de comandos para el análisis y monitoreo de redes. La gestión, construcción, prueba y empaquetado del proyecto se realizan de forma automatizada a través de `make`.

## Estructura del Directorio

```
.
├── Makefile
├── docs
│   ├── bitacora-sprint-1.md
│   ├── bitacora-sprint-2.md
│   ├── bitacora-sprint-3.md
│   ├── contrato-salidas.md
│   └── README.md
├── out
├── src
│   ├── dns-utils.sh
│   ├── handshake_analizer.sh
│   ├── monitor-red.sh
│   └── servicio_http_eco.sh
├── systemd
│   ├── servicio-eco.env
│   ├── servicio-eco.env.template
│   └── servicio-eco.service
└── tests
    ├── dns-resolucion.bats
    ├── systemd-validation.bats
    └── test-http-service.bats
```

## Instrucciones de Uso

### Requisitos Previos

Asegúrese de tener las siguientes herramientas instaladas:
- `nc` (netcat)
- `curl`
- `dig`
- `openssl`
- `bats`

Puede verificar si todas las herramientas necesarias están instaladas ejecutando:

```bash
make tools
```

### Comandos Principales

- **`make help`**: Muestra todos los comandos disponibles en el `Makefile`.
- **`make build`**: Genera artefactos y evidencias de la ejecución de los scripts.
- **`make run`**: Inicia el servidor HTTP eco en el puerto por defecto (8080).
- **`make test`**: Ejecuta todas las pruebas automatizadas para DNS, HTTP y systemd.
- **`make pack`**: Empaqueta el proyecto en un archivo `tar.gz` para su distribución.
- **`make clean`**: Elimina los directorios de artefactos y distribución.

### Módulos y Funcionalidades

#### Servidor HTTP Eco

El script `src/servicio_http_eco.sh` levanta un servidor HTTP que tiene los siguientes endpoints:
- **`GET /salud`**: Devuelve un estado `200 OK` para indicar que el servicio está operativo.
- **`POST /eco`**: Devuelve el mismo cuerpo que se le envía en la petición.

#### Análisis de Red y DNS

- **`make run-dns`**: Ejecuta el script `src/dns-utils.sh` para realizar un análisis de los registros DNS de un dominio.
- **`make monitor-red`**: Ejecuta `src/monitor-red.sh` para verificar la conectividad y los puertos abiertos de los hosts especificados.
- **`make build`**: Ejecuta `src/handshake_analizer.sh` para capturar y analizar las trazas de una petición HTTP a un servidor local y una petición HTTPS a un servidor público, inspeccionando el handshake TLS de este último.

#### Integración con Systemd

El proyecto incluye archivos para configurar el servidor como un servicio de `systemd`.
- **`make systemd-setup`**: Configura e instala el servicio `servicio-eco.service` en el directorio de systemd del usuario.
- **`make systemd-test`**: Inicia, verifica el estado y detiene el servicio de systemd para comprobar su correcto funcionamiento.
- **`make systemd-logs`**: Muestra los logs del servicio en tiempo real.

### Pruebas

El proyecto utiliza `bats` para las pruebas automatizadas.
- **`make test-dns`**: Ejecuta las pruebas de resolución de DNS.
- **`make test-http`**: Ejecuta las pruebas del servicio HTTP eco.
- **`make test-systemd`**: Ejecuta las pruebas de validación de la configuración de systemd.

## Variables de Entorno

El comportamiento de los scripts y comandos de `make` puede ser modificado a través de las siguientes variables de entorno:

| Variable | Descripción | Valor por defecto |
|---|---|---|
| `PORT` | Puerto en el que corre el servidor web | 8080 |
| `HOST` | Host en el que corre el servidor web | localhost |
| `RELEASE` | Versión del release para el empaquetado | v0.1.0 |
| `MONITOR_HOSTS` | Hosts a monitorear | localhost google.com |
| `MONITOR_PORTS` | Puertos a monitorear | 80 443 8080 53 |
| `DNS_SERVER` | Servidor DNS a utilizar para las consultas | (vacío, usa el del sistema) |
| `DOMINIO` | Dominio para el análisis DNS | localhost |
| `TARGET_HOST` | Host remoto para pruebas de handshake | example.org |
| `TARGET_PORT` | Puerto remoto para pruebas de handshake | 443 |

## Contrato de Salidas

Para una descripción detallada de los artefactos generados por los diferentes comandos, consulte el archivo `docs/contrato-salidas.md`.