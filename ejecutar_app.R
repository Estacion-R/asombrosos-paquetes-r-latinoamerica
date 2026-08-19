#!/usr/bin/env Rscript
# Script rápido para ejecutar la aplicación Shiny
# Ejecutar desde el directorio raíz del proyecto

cat("\n")
cat("========================================\n")
cat("  Asombrosos Paquetes de R - Shiny App\n")
cat("========================================\n\n")

# Verificar que estamos en el directorio correcto
if (!dir.exists("app")) {
  stop("Error: No se encuentra el directorio 'app/'. Ejecuta este script desde la raíz del proyecto.")
}

# Verificar que existe app.R
if (!file.exists("app/app.R")) {
  stop("Error: No se encuentra 'app/app.R'.")
}

cat("📁 Directorio del proyecto detectado correctamente\n")
cat("🚀 Iniciando aplicación Shiny...\n\n")

# Ejecutar la app
shiny::runApp("app/")
