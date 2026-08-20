# Catálogo de Paquetes R — Estación R

library(shiny)
library(tidyverse)
library(yaml)
library(DT)
library(bslib)
library(shinyWidgets)

# Leer datos desde YAML (fuente de verdad en el repo)
leer_paquetes <- function() {
  tryCatch({
    ruta_yaml <- file.path(dirname(getwd()), "data", "paquetes.yaml")
    if (!file.exists(ruta_yaml)) ruta_yaml <- "../data/paquetes.yaml"
    raw <- yaml::read_yaml(ruta_yaml)$paquetes
    purrr::map_df(raw, function(p) {
      tibble(
        nro_tematica = as.integer(p$categoria),
        paquete      = p$nombre,
        link         = p$url,
        descripcion  = p$descripcion,
        autor_es     = p$autores,
        pais         = p$pais,
        icono        = if (!is.null(p$hexlogo)) p$hexlogo else NA_character_,
        vigente      = isTRUE(p$vigente)
      )
    })
  }, error = function(e) {
    warning("No se pudo leer data/paquetes.yaml: ", conditionMessage(e))
    return(NULL)
  })
}

paquetes <- leer_paquetes()

# Mapeo de categorías
categorias <- c(
  "1" = "Datos Oficiales",
  "2" = "Datos Espaciales",
  "3" = "Temáticas Específicas",
  "4" = "Tratamiento de Datos",
  "5" = "Modelado",
  "6" = "Visualización",
  "7" = "Datasets",
  "8" = "Enseñanza"
)

# Tema oficial Estación R — spec visual minimalista + paleta oficial
# Ref: memory/spec-visual-shiny-estacion-r.md
tema_estacion_r <- bs_theme(
  version      = 5,
  bg           = "#FFFFFF",
  fg           = "#151515",
  primary      = "#447099",
  secondary    = "#707073",
  success      = "#72994E",
  info         = "#419599",
  warning      = "#EE6331",
  danger       = "#9A4665",
  base_font    = font_google("Ubuntu"),
  heading_font = font_google("Ubuntu", wght = c(400, 500, 700)),
  font_scale   = 1
)

# UI
ui <- page_fluid(
  theme = tema_estacion_r,

  # CSS personalizado
  tags$head(
    tags$link(rel = "stylesheet", href = "custom.css"),
    tags$style(HTML("
      /* === Hero === */
      .hero-section {
        background: #FFFFFF;
        padding: 3rem 0 2rem 0;
        border-bottom: 3px solid #151515;
        margin-bottom: 0;
        border-radius: 0;
      }
      .hero-title {
        font-size: 3rem;
        font-weight: 700;
        color: #151515;
        letter-spacing: -1px;
        margin-bottom: 0.5rem;
        text-shadow: none;
      }
      .hero-subtitle {
        font-size: 1.2rem;
        color: #151515;
        opacity: 1;
        margin-bottom: 1rem;
      }
      /* === Stats cards === */
      .stats-card {
        background: #FFFFFF;
        border: 2px solid #151515;
        border-radius: 0;
        padding: 1.5rem;
        text-align: center;
        box-shadow: 4px 4px 0 #EAFF38;
        transition: all 0.2s ease;
      }
      .stats-card:hover {
        transform: translateY(-4px);
        box-shadow: 6px 6px 0 #EAFF38;
      }
      .stats-number {
        font-size: 2.5rem;
        font-weight: 700;
        color: #447099;
        margin: 0.5rem 0;
      }
      .stats-label {
        color: #707073;
        font-size: 0.85rem;
        text-transform: uppercase;
        letter-spacing: 1px;
      }
      /* === Filter card === */
      .filter-card {
        background: #FFFFFF;
        border: 2px solid #151515;
        border-radius: 0;
        padding: 1.5rem;
        margin-bottom: 1.5rem;
        box-shadow: 4px 4px 0 #EAFF38;
      }
      /* === Package cards === */
      .package-card {
        background: #FFFFFF;
        border: 2px solid #151515;
        border-radius: 0;
        padding: 1.5rem;
        margin-bottom: 1.5rem;
        box-shadow: 4px 4px 0 #EAFF38;
        transition: all 0.2s ease;
        cursor: pointer;
      }
      .package-card:hover {
        transform: translateY(-4px);
        box-shadow: 8px 8px 0 #EAFF38;
        border-color: #447099;
      }
      .package-name {
        font-size: 1.5rem;
        font-weight: 700;
        color: #151515;
        margin-bottom: 0.5rem;
      }
      /* === Badges === */
      .package-country {
        display: inline-block;
        background: #EE6331;
        color: #151515;
        padding: 0.25rem 0.75rem;
        border: 2px solid #151515;
        border-radius: 0;
        font-size: 0.85rem;
        font-weight: 500;
        margin-right: 0.5rem;
      }
      .package-category {
        display: inline-block;
        background: #419599;
        color: #FFFFFF;
        padding: 0.25rem 0.75rem;
        border: 2px solid #151515;
        border-radius: 0;
        font-size: 0.85rem;
        font-weight: 500;
      }
      /* === Footer === */
      .footer-brand {
        text-align: center;
        padding: 2rem 1.5rem;
        background: #151515;
        color: #FFFFFF;
        margin-top: 4rem;
        border-top: 3px solid #151515;
        border-radius: 0;
      }
      .footer-brand p, .footer-brand h5 {
        color: #FFFFFF;
      }
      .footer-brand a {
        color: #EE6331;
        text-decoration: none;
        font-weight: 500;
      }
      .footer-brand a:hover {
        color: #447099;
        text-decoration: underline;
      }
      /* === Botón Estación === */
      .btn-estacion {
        background: #447099;
        color: #FFFFFF;
        border: 2px solid #151515;
        border-radius: 0;
        padding: 0.75rem 1.5rem;
        font-weight: 500;
        transition: all 0.2s ease;
      }
      .btn-estacion:hover {
        background: #151515;
        color: #EE6331;
        transform: translateX(4px);
      }
      /* === Inputs === */
      .form-control, .form-select, .btn {
        border-radius: 0;
      }
      .form-control:focus, .form-select:focus {
        border-color: #447099;
        box-shadow: 2px 2px 0 #EAFF38;
        outline: none;
      }
      /* === Animación === */
      @keyframes fadeInUp {
        from { opacity: 0; transform: translateY(20px); }
        to   { opacity: 1; transform: translateY(0); }
      }
      .package-card { animation: fadeInUp 0.4s ease-out; }
      html { scroll-behavior: smooth; }
    "))
  ),

  # Hero Section
  div(
    class = "hero-section",
    div(
      class = "container",
      div(
        class = "row",
        div(
          class = "col-md-12 text-center",
          # Logo de Estación R
          tags$img(
            src = "img/logo_estacion_r_ancho.png",
            alt = "Estación R",
            style = "height: 80px; margin-bottom: 25px;"
          ),
          h1(class = "hero-title", "📦 Asombrosos Paquetes de R"),
          h2(class = "hero-subtitle", "Descubrí paquetes desarrollados por talento latinoamericano"),
          p(style = "margin-top: 20px; font-size: 1.05rem;",
            "Una colección curada de herramientas de código abierto creadas en Latinoamérica",
            br(),
            "para análisis de datos, visualización y mucho más"
          )
        )
      )
    )
  ),

  # Contenedor principal
  div(
    class = "container",
    style = "margin-top: -20px;",

    # Estadísticas generales
    fluidRow(
      column(
        4,
        div(
          class = "stats-card",
          icon("cube", style = "font-size: 2rem; color: #447099;"),
          div(class = "stats-number", textOutput("total_paquetes", inline = TRUE)),
          div(class = "stats-label", "Paquetes")
        )
      ),
      column(
        4,
        div(
          class = "stats-card",
          icon("globe-americas", style = "font-size: 2rem; color: #72994E;"),
          div(class = "stats-number", textOutput("total_paises", inline = TRUE)),
          div(class = "stats-label", "Países")
        )
      ),
      column(
        4,
        div(
          class = "stats-card",
          icon("folder-open", style = "font-size: 2rem; color: #419599;"),
          div(class = "stats-number", textOutput("total_categorias", inline = TRUE)),
          div(class = "stats-label", "Categorías")
        )
      )
    ),

    # Filtros
    div(
      class = "filter-card",
      style = "margin-top: 30px;",
      h4(icon("filter"), " Filtrar Paquetes", style = "margin-bottom: 20px; color: #447099;"),
      fluidRow(
        column(
          4,
          pickerInput(
            inputId = "pais",
            label = "País:",
            choices = c("Todos" = ""),
            selected = "",
            options = list(
              `live-search` = TRUE,
              `style` = "btn-outline-primary"
            )
          )
        ),
        column(
          4,
          pickerInput(
            inputId = "categoria",
            label = "Categoría:",
            choices = c("Todas" = "", categorias),
            selected = "",
            options = list(
              `style` = "btn-outline-primary"
            )
          )
        ),
        column(
          4,
          searchInput(
            inputId = "busqueda",
            label = "Buscar:",
            placeholder = "Nombre, descripción, autor...",
            btnSearch = icon("search"),
            btnReset = icon("remove"),
            width = "100%"
          )
        )
      ),
      div(
        style = "text-align: right; margin-top: 15px;",
        actionButton(
          inputId = "limpiar",
          label = "Limpiar filtros",
          icon = icon("eraser"),
          class = "btn-outline-secondary btn-sm"
        )
      )
    ),

    # Resultados
    div(
      style = "margin-top: 30px;",
      uiOutput("resultados_info"),
      uiOutput("lista_paquetes")
    ),

    # Footer
    div(
      class = "footer-brand",
      # Logo de Estación R
      tags$img(
        src = "img/logo_estacion_r_ancho.png",
        alt = "Estación R",
        style = "height: 60px; margin-bottom: 20px;"
      ),
      h5(style = "color: #447099; margin-bottom: 20px;",
         icon("heart"), " Desarrollado por Estación R"),
      p("Escuela de Datos - Formación en R y Ciencia de Datos"),
      div(
        style = "margin-top: 20px;",
        actionButton(
          inputId = "contribuir",
          label = "Proponer un paquete",
          icon = icon("plus-circle"),
          class = "btn-estacion",
          style = "margin-right: 10px;",
          onclick = "window.open('https://github.com/Estacion-R/asombrosos-paquetes-r-latinoamerica/issues/new/choose', '_blank')"
        ),
        actionButton(
          inputId = "ir_repo",
          label = "Ver en GitHub",
          icon = icon("github"),
          class = "btn-outline-primary",
          onclick = "window.open('https://github.com/Estacion-R/asombrosos-paquetes-r-latinoamerica', '_blank')"
        )
      ),
      p(style = "margin-top: 30px; color: #707073; font-size: 0.9rem;",
        "© 2025 Estación R | Todos los paquetes son propiedad de sus respectivos autores")
    )
  )
)

# Server
server <- function(input, output, session) {

  # Verificar que se cargaron los datos
  if (is.null(paquetes)) {
    showModal(modalDialog(
      title = "Error al cargar datos",
      "No se pudieron cargar los paquetes desde Google Sheets. Por favor, intenta más tarde.",
      easyClose = TRUE,
      footer = NULL
    ))
  }

  # Actualizar opciones de país basado en datos disponibles
  observe({
    if (!is.null(paquetes)) {
      paises_disponibles <- sort(unique(na.omit(paquetes$pais)))
      updatePickerInput(
        session,
        "pais",
        choices = c("Todos" = "", paises_disponibles)
      )
    }
  })

  # Limpiar filtros
  observeEvent(input$limpiar, {
    updatePickerInput(session, "pais", selected = "")
    updatePickerInput(session, "categoria", selected = "")
    updateSearchInput(session, "busqueda", value = "")
  })

  # Datos filtrados reactivos
  datos_filtrados <- reactive({
    req(paquetes)
    datos <- paquetes

    # Filtro por país
    if (!is.null(input$pais) && input$pais != "") {
      datos <- datos %>% filter(pais == input$pais)
    }

    # Filtro por categoría
    if (!is.null(input$categoria) && input$categoria != "") {
      datos <- datos %>% filter(nro_tematica == as.integer(input$categoria))
    }

    # Filtro por búsqueda
    if (!is.null(input$busqueda) && input$busqueda != "") {
      busqueda_lower <- tolower(input$busqueda)
      datos <- datos %>%
        filter(
          str_detect(tolower(paquete), busqueda_lower) |
            str_detect(tolower(descripcion), busqueda_lower) |
            str_detect(tolower(autor_es), busqueda_lower)
        )
    }

    datos
  })

  # Estadísticas en header
  output$total_paquetes <- renderText({
    req(datos_filtrados())
    nrow(datos_filtrados())
  })

  output$total_paises <- renderText({
    req(datos_filtrados())
    n_distinct(datos_filtrados()$pais, na.rm = TRUE)
  })

  output$total_categorias <- renderText({
    req(datos_filtrados())
    n_distinct(datos_filtrados()$nro_tematica)
  })

  # Info de resultados
  output$resultados_info <- renderUI({
    req(datos_filtrados())
    total <- nrow(datos_filtrados())

    div(
      style = "margin-bottom: 20px;",
      h4(
        style = "color: #447099;",
        icon("list"),
        sprintf(" Mostrando %d paquete%s", total, ifelse(total != 1, "s", ""))
      )
    )
  })

  # Lista de paquetes como tarjetas
  output$lista_paquetes <- renderUI({
    req(datos_filtrados())
    datos <- datos_filtrados()

    if (nrow(datos) == 0) {
      return(
        div(
          class = "text-center",
          style = "padding: 60px 20px;",
          icon("search", style = "font-size: 4rem; color: #ccc;"),
          h4("No se encontraron paquetes", style = "color: #707073; margin-top: 20px;"),
          p("Intenta ajustar los filtros de búsqueda")
        )
      )
    }

    # Crear tarjetas para cada paquete
    tarjetas <- lapply(1:nrow(datos), function(i) {
      pkg <- datos[i, ]

      # Obtener nombre de categoría
      categoria_texto <- categorias[as.character(pkg$nro_tematica)]
      if (is.na(categoria_texto) || is.null(categoria_texto)) {
        categoria_texto <- "Sin categoría"
      }

      div(
        class = "package-card",
        onclick = sprintf("window.open('%s', '_blank')", pkg$link),

        # Header con ícono y nombre
        div(
          style = "display: flex; align-items: center; justify-content: space-between; margin-bottom: 15px;",
          div(
            style = "display: flex; align-items: center;",
            if (!is.na(pkg$icono) && pkg$icono != "") {
              tags$img(
                src = pkg$icono,
                height = "50px",
                style = "margin-right: 15px; border-radius: 8px;",
                onerror = "this.style.display='none'; this.nextElementSibling.style.display='inline-block';"
              )
            },
            # Ícono de fallback (siempre presente pero oculto si la imagen carga)
            icon("cube", style = sprintf(
              "font-size: 2.5rem; color: #447099; margin-right: 15px; display: %s;",
              if (!is.na(pkg$icono) && pkg$icono != "") "none" else "inline-block"
            )),
            div(
              div(class = "package-name", pkg$paquete),
              div(
                span(class = "package-country", icon("map-marker-alt"), " ", pkg$pais),
                span(class = "package-category", categoria_texto)
              )
            )
          ),
          icon("external-link-alt", style = "color: #447099; font-size: 1.2rem;")
        ),

        # Descripción
        div(
          style = "margin-bottom: 12px; color: #151515; line-height: 1.6;",
          pkg$descripcion
        ),

        # Autores
        div(
          style = "color: #707073; font-size: 0.9rem; border-top: 1px solid #C2C2C4; padding-top: 12px;",
          icon("users"),
          " ",
          strong("Autores: "),
          pkg$autor_es
        )
      )
    })

    # Devolver todas las tarjetas
    do.call(tagList, tarjetas)
  })
}

# Ejecutar la aplicación
shinyApp(ui = ui, server = server)
