# Catálogo de Paquetes R — Estación R

library(shiny)
library(tidyverse)
library(yaml)
library(DT)
library(bslib)
library(shinyWidgets)
library(leaflet)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)

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

# Preparar datos del mapa: conteo de paquetes por país + shapes de rnaturalearth
preparar_datos_mapa <- function(paquetes_df) {
  conteo <- paquetes_df %>%
    filter(!is.na(pais), pais != "No especificado") %>%
    count(pais, name = "n_paquetes")
  
  # Shapes de países de las Américas
  sudamerica <- ne_countries(continent = "South America", returnclass = "sf")
  norteamerica <- ne_countries(continent = "North America", returnclass = "sf")
  shapes <- rbind(sudamerica, norteamerica)
  
  # Merge conteo con shapes (name_en coincide con nuestros valores de pais)
  shapes <- shapes %>%
    left_join(conteo, by = c("name_en" = "pais")) %>%
    mutate(n_paquetes = ifelse(is.na(n_paquetes), 0, n_paquetes))
  
  shapes
}

shapes_mapa <- preparar_datos_mapa(paquetes)
max_paquetes <- max(shapes_mapa$n_paquetes, na.rm = TRUE)

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

  # Contenedor principal con tabs
  div(
    class = "container",
    style = "margin-top: -20px;",

    navset_card_tab(
      id = "tab_principal",
      nav_panel(
        title = icon("list", " Catálogo"),
        value = "tab_catalogo",

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
        )
      ),

      nav_panel(
        title = icon("map", " Mapa"),
        value = "tab_mapa",

        # Header del mapa
        div(
          style = "margin-bottom: 20px;",
          # Output oculto para que conditionalPanel pueda evaluar la condición
          textOutput("mapa_hay_seleccion", inline = TRUE),
          tags$style("#mapa_hay_seleccion{display: none;}"),
          h4(icon("globe-americas"), " Paquetes por país", style = "color: #447099; margin-bottom: 10px;"),
          p(style = "color: #6c757d;", "Hacé clic en un país para filtrar el catálogo."),
          conditionalPanel(
            condition = "output.mapa_hay_seleccion",
            div(
              style = "margin-top: 10px; padding: 10px 15px; background: #f8f9fa; border-radius: 8px; border-left: 4px solid #447099;",
              uiOutput("mapa_pais_seleccionado")
            )
          )
        ),

        # Mapa leaflet
        leafletOutput("mapa_paquetes", height = "500px"),

        # Botón para limpiar filtro del mapa
        div(
          style = "text-align: center; margin-top: 15px;",
          actionButton(
            inputId = "limpiar_mapa",
            label = "Mostrar todos los países",
            icon = icon("eraser"),
            class = "btn-outline-secondary btn-sm"
          )
        )
      )
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

  # --- Mapa interactivo ---

  # Flag para mostrar/ocultar info del país seleccionado en el mapa
  mapa_pais_sel <- reactiveVal(NULL)

  # Output auxiliar para conditionalPanel (debe ser textOutput inline)
  output$mapa_hay_seleccion <- renderText({
    if (is.null(mapa_pais_sel())) "false" else "true"
  })

  # Paleta de colores para el mapa (claro → azul oscuro según densidad)
  paleta_mapa <- colorNumeric(
    palette = c("#E8F0F5", "#447099", "#151515"),
    domain = c(0, max_paquetes),
    na.color = "#F0F0F0"
  )

  # Renderizar mapa leaflet
  output$mapa_paquetes <- renderLeaflet({
    req(shapes_mapa)

    pal <- paleta_mapa

    leaflet(shapes_mapa) |>
      addTiles() |>
      addPolygons(
        layerId = ~name_en,
        fillColor = ~pal(n_paquetes),
        fillOpacity = 0.7,
        color = "#151515",
        weight = 1.5,
        dashArray = "",
        highlight = highlightOptions(
          weight = 3,
          color = "#EE6331",
          dashArray = "",
          fillOpacity = 0.5,
          bringToFront = TRUE
        ),
        label = sprintf(
          "%s: %d paquete%s",
          shapes_mapa$name_en,
          shapes_mapa$n_paquetes,
          ifelse(shapes_mapa$n_paquetes != 1, "s", "")
        ),
        labelOptions = labelOptions(
          style = list("font-weight" = "bold", "color" = "#151515"),
          textsize = "14px",
          direction = "auto"
        )
      ) |>
      setView(lng = -60, lat = -15, zoom = 3) |>
      addLegend(
        position = "bottomright",
        pal = pal,
        values = ~n_paquetes,
        title = "Paquetes",
        opacity = 0.7,
        labFormat = labelFormat(big.mark = ".")
      )
  })

  # Click en un país del mapa → filtrar catálogo
  observeEvent(input$mapa_paquetes_shape_click, {
    click <- input$mapa_paquetes_shape_click
    if (is.null(click)) return()

    pais_click <- click$id
    mapa_pais_sel(pais_click)

    # Actualizar el filtro de país del catálogo
    updatePickerInput(session, "pais", selected = pais_click)

    # Cambiar a la pestaña del catálogo
    updateNavsetCardTab(session, "tab_principal", selected = "tab_catalogo")
  })

  # Info del país seleccionado en el mapa
  output$mapa_pais_seleccionado <- renderUI({
    pais <- mapa_pais_sel()
    if (is.null(pais)) return(NULL)
    n <- sum(paquetes$pais == pais, na.rm = TRUE)
    div(
      strong(icon("filter"), " Filtrando por: ", pais),
      span(style = "color: #6c757d;", sprintf(" (%d paquete%s)", n, ifelse(n != 1, "s", "")))
    )
  })

  # Limpiar filtro del mapa
  observeEvent(input$limpiar_mapa, {
    mapa_pais_sel(NULL)
    updatePickerInput(session, "pais", selected = "")
  })

  # Cuando se limpia el filtro general, también limpiar info del mapa
  observeEvent(input$limpiar, {
    mapa_pais_sel(NULL)
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
