# Script de prueba para la aplicación Shiny
# Ejecutar este script para probar localmente antes de desplegar

cat("=== Test de Aplicación Shiny - Asombrosos Paquetes ===\n\n")

# 1. Verificar librerías instaladas
cat("1. Verificando librerías...\n")
paquetes_necesarios <- c("shiny", "tidyverse", "googlesheets4", "DT", "bslib", "shinyWidgets")

verificar_paquetes <- function(paquetes) {
  faltantes <- c()
  for (pkg in paquetes) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      faltantes <- c(faltantes, pkg)
    }
  }
  return(faltantes)
}

faltantes <- verificar_paquetes(paquetes_necesarios)

if (length(faltantes) > 0) {
  cat("❌ Faltan los siguientes paquetes:\n")
  cat(paste("  -", faltantes, collapse = "\n"), "\n\n")
  cat("Instalar con: install.packages(c('", paste(faltantes, collapse = "', '"), "'))\n\n")
  stop("Instala los paquetes faltantes antes de continuar.")
} else {
  cat("✅ Todas las librerías están instaladas\n\n")
}

# 2. Probar conexión a Google Sheets
cat("2. Probando conexión a Google Sheets...\n")
library(googlesheets4)
gs4_deauth()

url_sheet <- "https://docs.google.com/spreadsheets/d/1xcYY1RkvOxnJlANMPtzhbdrpUgtSdF7IoEtNzE6zRKk/edit?usp=sharing"

tryCatch({
  paquetes_test <- read_sheet(url_sheet)
  cat("✅ Conexión exitosa al Google Sheet\n")
  cat("   Paquetes encontrados:", nrow(paquetes_test), "\n\n")

  # Mostrar muestra de datos
  cat("   Muestra de datos:\n")
  print(head(paquetes_test[, c("paquete", "pais", "autor_es")], 3))
  cat("\n")

}, error = function(e) {
  cat("❌ Error al conectar con Google Sheets:\n")
  cat("   ", e$message, "\n\n")
  stop("No se pudo cargar los datos.")
})

# 3. Verificar estructura de datos
cat("3. Verificando estructura de datos...\n")
columnas_requeridas <- c("paquete", "link", "descripcion", "autor_es", "pais", "nro_tematica")
columnas_existentes <- names(paquetes_test)

columnas_faltantes <- setdiff(columnas_requeridas, columnas_existentes)

if (length(columnas_faltantes) > 0) {
  cat("❌ Faltan las siguientes columnas en el Google Sheet:\n")
  cat(paste("  -", columnas_faltantes, collapse = "\n"), "\n\n")
  warning("Revisa la estructura del Google Sheet")
} else {
  cat("✅ Estructura de datos correcta\n\n")
}

# 4. Estadísticas básicas
cat("4. Estadísticas de los datos:\n")
cat("   Total de paquetes:", nrow(paquetes_test), "\n")
cat("   Países únicos:", n_distinct(paquetes_test$pais, na.rm = TRUE), "\n")
cat("   Categorías únicas:", n_distinct(paquetes_test$nro_tematica), "\n\n")

# Contar por país
cat("   Distribución por país:\n")
paquetes_test %>%
  count(pais, sort = TRUE) %>%
  head(5) %>%
  print()

cat("\n")

# 5. Verificar que app.R existe
cat("5. Verificando archivos de la app...\n")
if (file.exists("app.R")) {
  cat("✅ app.R encontrado\n")
} else {
  cat("❌ app.R no encontrado\n")
  stop("Ejecuta este script desde el directorio app/")
}

if (dir.exists("www")) {
  cat("✅ Directorio www/ encontrado\n")
} else {
  cat("⚠️  Directorio www/ no encontrado (opcional)\n")
}

cat("\n")

# 6. Todo listo para ejecutar
cat("========================================\n")
cat("✅ ¡Todo listo para ejecutar la app!\n")
cat("========================================\n\n")
cat("Para ejecutar la aplicación:\n\n")
cat("  shiny::runApp()\n\n")
cat("O desde RStudio, abre app.R y haz clic en 'Run App'\n\n")

# Preguntar si quiere ejecutar ahora
respuesta <- readline(prompt = "¿Ejecutar la app ahora? (s/n): ")

if (tolower(respuesta) == "s") {
  cat("\n🚀 Iniciando aplicación Shiny...\n\n")
  shiny::runApp()
} else {
  cat("\n👍 Ejecuta shiny::runApp() cuando estés listo.\n")
}
