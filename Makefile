# Variables de entorno 
PORT ?= 8080
HOST ?= localhost
RELEASE ?= v0.1.0

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