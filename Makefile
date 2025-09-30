# Variables de entorno 
PORT ?= 8080
HOST ?= localhost
RELEASE ?= v0.1.0
DNS_SERVER ?=
DOMINIO ?= localhost 
MONITOR_HOSTS ?= localhost google.com
MONITOR_PORTS ?= 80 443 8080 53

# Directorios
SRC_DIR := src
DOCS_DIR := docs
OUT_DIR := out
DIST_DIR := dist
TEST_DIR := tests

# Archivo de empaquetado
DIST_FILE := $(DIST_DIR)/proyecto-$(RELEASE).tar.gz

# Lista de herramientas
TOOLS = nc curl dig openssl bats

.PHONY: tools build run test pack clean help

help:
	@echo "Uso: make <target>"
	@echo ""
	@echo "Targets disponibles:"
	@echo "  tools   - Verificar herramientas necesarias ($(TOOLS))"
	@echo "  build   - Generar artefactos intermedios en $(OUT_DIR)/"
	@echo "  run     - Iniciar el servicio eco"
	@echo "  test    - Ejecutar prueba básica con curl"
	@echo "  pack    - Empaquetar release en $(DIST_DIR)"
	@echo "  clean   - Limpiar artefactos"

tools:
	@echo "Verificando que herramientas necesarias estén instaladas..."
	@for tool in $(TOOLS); do \
		if ! command -v $$tool >/dev/null 2>&1; then \
			echo "Falta instalar $$tool"; \
			exit 1; \
		else \
			echo "$$tool disponible"; \
		fi; \
	done

build:

test:

run:
	@PORT=$(PORT) HOST=$(HOST) bash $(SRC_DIR)/servicio_http_eco.sh

$(DIST_FILE): $(SRC_DIR)/* $(DOCS_DIR)/* Makefile
	@echo "Empaquetando proyecto en $@..."
	@mkdir -p $(DIST_DIR)
	@tar -czf $@ $(SRC_DIR) $(DOCS_DIR) Makefile

pack: $(DIST_FILE)
	@echo "Empaquetado listo: $(DIST_FILE)"

clean:
	@echo "Limpiando $(OUT_DIR)/ y $(DIST_DIR)/..."
	@rm -rf $(OUT_DIR) $(DIST_DIR)

.PHONY: tools-dns test-dns run-dns systemd-setup systemd-test

# Verificar herramientas DNS
tools-dns:
	@echo "Verificando herramientas DNS..."
	@for tool in dig; do \
		command -v $$tool >/dev/null 2>&1 || { echo "Falta $$tool"; exit 1; } \
	done
	@echo "Todas las herramientas DNS disponibles"

# Ejecutar analisis DNS
run-dns:
	@mkdir -p $(OUT_DIR)
	@echo "Ejecutando análisis DNS y guardando en $(OUT_DIR)..."
	@DNS_SERVER=$(DNS_SERVER) DOMINIO=$(DOMINIO) bash src/dns-utils.sh | tee $(OUT_DIR)/dns-analysis-$$(date +%Y%m%d-%H%M%S).txt

# Ejecutar pruebas DNS
test-dns:
	@echo "Ejecutando pruebas DNS..."
	@DNS_SERVER=$(DNS_SERVER) DOMINIO=$(DOMINIO) bats tests/dns-resolucion.bats

# Configurar unidad systemd
systemd-setup:
	@echo "Configurando unidad systemd..."
	@mkdir -p ~/.config/systemd/user/
	@sed -e 's|/path/to/src/dns-utils.sh|$(shell pwd)/src/dns-utils.sh|' \
	     -e 's|%E{DNS_SERVER}|8.8.8.8|g' \
	     -e 's|%E{DOMINIO:-localhost}|localhost|g' \
	     systemd/servicio-eco.service > ~/.config/systemd/user/servicio-eco.service
	@systemctl --user daemon-reload
	@echo "Unidad systemd configurada"

# Probar unidad systemd
systemd-test:
	@echo "Probando unidad systemd..."
	@systemctl --user start servicio-eco
	@sleep 2
	@systemctl --user status servicio-eco || true
	@systemctl --user stop servicio-eco
	@echo "Prueba de unidad systemd completada"

.PHONY: monitor-red test-negativos test-systemd systemd-install

# Monitoreo de red
monitor-red:
	@echo "Ejecutando monitoreo de red..."
	@HOSTS="$(MONITOR_HOSTS)" PORTS="$(MONITOR_PORTS)" bash src/monitor-red.sh

test-systemd:
	@echo "Validando configuracion systemd..."
	@bats tests/systemd-validation.bats

# Instalacion systemd avanzada
systemd-install:
	@echo "Instalando servicio systemd avanzado..."
	@mkdir -p ~/.config/systemd/user/
	@cp systemd/servicio-eco.service ~/.config/systemd/user/
	@cp systemd/servicio-eco.env.template ~/.config/systemd/user/servicio-eco.env
	@systemctl --user daemon-reload
	@echo "Servicio instalado. Edita ~/.config/systemd/user/servicio-eco.env para configurar"

# Target completo para todas las pruebas extendidas
test-extendido: test-dns test-systemd
	@echo "Todas las pruebas extendidas completadas"
