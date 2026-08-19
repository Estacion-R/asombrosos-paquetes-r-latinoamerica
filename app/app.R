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

# Tema oficial Estación R
# Ref: Proyectos/_activos/identidad_visual/GUIA_DE_ESTILO.md
tema_estacion_r <- bs_theme(
  version      = 5,
  bg           = "#FFFFFF",
  fg           = "#191919",
  primary      = "#405BFF",
  secondary    = "#EAFF38",
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
      .hero-section {
        background: linear-gradient(135deg, #447099 0%, #419599 100%);
        color: white;
        padding: 60px 20px;
        margin-bottom: 40px;
        border-radius: 0 0 20px 20px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.1);
      }
      .hero-title {
        font-size: 2.5rem;
        font-weight: 700;
        margin-bottom: 15px;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
      }
      .hero-subtitle {
        font-size: 1.2rem;
        opacity: 0.95;
        margin-bottom: 20px;
      }
      .stats-card {
        background: white;
        border-radius: 12px;
        padding: 20px;
        text-align: center;
        box-shadow: 0 2px 10px rgba(0,0,0,0.08);
        border-left: 4px solid #447099;
        transition: all 0.3s ease;
      }
      .stats-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 6px 20px rgba(0,0,0,0.15);
      }
      .stats-number {
        font-size: 2.5rem;
        font-weight: 700;
        color: #447099;
        margin: 10px 0;
      }
      .stats-label {
        color: #6c757d;
        font-size: 0.95rem;
        text-transform: uppercase;
        letter-spacing: 1px;
      }
      .filter-card {
        background: #f8f9fa;
        border-radius: 12px;
        padding: 25px;
        margin-bottom: 20px;
        border: 1px solid #e9ecef;
      }
      .package-card {
        background: white;
        border-radius: 12px;
        padding: 20px;
        margin-bottom: 20px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        border-left: 4px solid #447099;
        transition: all 0.3s ease;
        cursor: pointer;
      }
      .package-card:hover {
        transform: translateY(-3px);
        box-shadow: 0 6px 16px rgba(0,0,0,0.12);
        border-left-color: #EE6331;
      }
      .package-name {
        font-size: 1.3rem;
        font-weight: 600;
        color: #447099;
        margin-bottom: 10px;
      }
      .package-country {
        display: inline-block;
        background: #72994E;
        color: white;
        padding: 3px 12px;
        border-radius: 15px;
        font-size: 0.85rem;
        margin-right: 8px;
      }
      .package-category {
        display: inline-block;
        background: #419599;
        color: white;
        padding: 3px 12px;
        border-radius: 15px;
        font-size: 0.85rem;
      }
      .footer-brand {
        text-align: center;
        padding: 40px 20px;
        background: #f8f9fa;
        margin-top: 60px;
        border-top: 3px solid #447099;
      }
      .btn-estacion {
        background: #EE6331;
        color: white;
        border: none;
        border-radius: 8px;
        padding: 10px 20px;
        font-weight: 600;
        transition: all 0.3s ease;
      }
      .btn-estacion:hover {
        background: #d45528;
        color: white;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(238, 99, 49, 0.3);
      }
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
            style = "height: 80px; margin-bottom: 25px; filter: brightness(0) invert(1);"
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
          onclick = "window.open('https://github.com/pablotis/asombrosos-paquetes-r-latinoamerica/issues/new/choose', '_blank')"
        ),
        actionButton(
          inputId = "ir_repo",
          label = "Ver en GitHub",
          icon = icon("github"),
          class = "btn-outline-primary",
          onclick = "window.open('https://github.com/pablotis/asombrosos-paquetes-r-latinoamerica', '_blank')"
        )
      ),
      p(style = "margin-top: 30px; color: #6c757d; font-size: 0.9rem;",
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
          h4("No se encontraron paquetes", style = "color: #6c757d; margin-top: 20px;"),
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
          style = "margin-bottom: 12px; color: #495057; line-height: 1.6;",
          pkg$descripcion
        ),

        # Autores
        div(
          style = "color: #6c757d; font-size: 0.9rem; border-top: 1px solid #e9ecef; padding-top: 12px;",
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
