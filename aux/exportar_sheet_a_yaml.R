library(googlesheets4)
library(dplyr)
library(yaml)
library(stringr)

gs4_deauth()
url_sheet <- "https://docs.google.com/spreadsheets/d/1xcYY1RkvOxnJlANMPtzhbdrpUgtSdF7IoEtNzE6zRKk/edit?usp=sharing"

cat("Leyendo Google Sheet...\n")
raw <- read_sheet(url_sheet)
cat("Filas leídas:", nrow(raw), "\n")
cat("Columnas:", paste(names(raw), collapse = ", "), "\n\n")

paquetes_lista <- raw |>
  filter(!is.na(paquete), paquete != "") |>
  rowwise() |>
  mutate(
    hexlogo_val = if (is.na(icono) || icono == "") NULL else icono
  ) |>
  ungroup() |>
  purrr::pmap(function(nro_tematica, paquete, link, descripcion, autor_es, icono, pais, ...) {
    entry <- list(
      nombre     = paquete,
      url        = link,
      descripcion = str_squish(descripcion),
      autores    = autor_es,
      pais       = if (is.na(pais) || pais == "") "No especificado" else pais,
      categoria  = as.integer(nro_tematica),
      vigente    = TRUE
    )
    if (!is.na(icono) && icono != "") entry$hexlogo <- icono
    entry
  })

salida <- list(paquetes = paquetes_lista)

ruta <- file.path(dirname(dirname(rstudioapi::getSourceEditorContext()$path)),
                  "data", "paquetes.yaml")

# Si no hay RStudio, usar path relativo
if (!requireNamespace("rstudioapi", quietly = TRUE) ||
    !rstudioapi::isAvailable()) {
  ruta <- "data/paquetes.yaml"
}

yaml::write_yaml(salida, ruta)
cat("Exportado a:", ruta, "\n")
cat("Total paquetes exportados:", length(paquetes_lista), "\n")
