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
        subcategoria = if (!is.null(p$subcategoria)) p$subcategoria else NA_character_,
        vigente      = isTRUE(p$vigente)
      )
    })
  }, error = function(e) {
    warning("No se pudo leer data/paquetes.yaml: ", conditionMessage(e))
    return(NULL)
  })
}

paquetes <- leer_paquetes()

# --- Conteo de paquetes por país (para el grid de países) ---
conteo_paises <- paquetes %>%
  filter(!is.na(pais), pais != "No especificado") %>%
  count(pais, name = "n_paquetes") %>%
  arrange(desc(n_paquetes))

# --- Conteo por categoría (para el grid de categorías) ---
conteo_categorias <- paquetes %>%
  count(nro_tematica, name = "n_paquetes") %>%
  arrange(nro_tematica)

# --- Conteo de subcategorías de Datos Oficiales ---
conteo_subcategorias <- paquetes %>%
  filter(nro_tematica == 1, !is.na(subcategoria)) %>%
  count(subcategoria, name = "n_paquetes")

# Etiquetas y emojis de categorías
categoria_emoji <- c(
  "1"  = "🏛️",
  "2"  = "🗺️",
  "4"  = "🔧",
  "5"  = "📊",
  "6"  = "🎨",
  "7"  = "📁",
  "8"  = "📚",
  "9"  = "🗳️",
  "10" = "☁️",
  "11" = "💰",
  "12" = "🧬"
)

subcategoria_label <- c(
  "censos"                  = "Censos",
  "encuestas"               = "Encuestas",
  "registros_administrativos" = "Registros administrativos"
)
subcategoria_emoji <- c(
  "censos"                  = "📋",
  "encuestas"               = "📝",
  "registros_administrativos" = "🗂️"
)

# Mapeo país (nombre en español) -> código ISO 3166-1 alpha-2 para banderas
pais_iso <- c(
  "Argentina"       = "ar",
  "Bolivia"         = "bo",
  "Brasil"          = "br",
  "Chile"           = "cl",
  "Colombia"        = "co",
  "Costa Rica"      = "cr",
  "Cuba"            = "cu",
  "Ecuador"         = "ec",
  "El Salvador"     = "sv",
  "Guatemala"       = "gt",
  "Honduras"        = "hn",
  "México"          = "mx",
  "Nicaragua"       = "ni",
  "Panama"          = "pa",
  "Paraguay"        = "py",
  "Perú"            = "pe",
  "Puerto Rico"     = "pr",
  "Dominican Republic" = "do",
  "Uruguay"         = "uy",
  "Venezuela"       = "ve",
  "No especificado" = NA_character_
)

# URL base para banderas SVG (flagcdn)
flag_url <- function(pais) {
  iso <- pais_iso[pais]
  if (is.na(iso) || is.na(pais)) return(NA_character_)
  sprintf("https://flagcdn.com/%s.svg", tolower(iso))
}

# Mapeo de categorías
categorias <- c(
  "1"  = "Datos Oficiales",
  "2"  = "Datos Espaciales",
  "4"  = "Tratamiento de Datos",
  "5"  = "Modelado",
  "6"  = "Visualización",
  "7"  = "Datasets",
  "8"  = "Enseñanza",
  "9"  = "Política y Elecciones",
  "10" = "Clima y Meteorología",
  "11" = "Economía",
  "12" = "Bioinformática"
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
        padding: 2rem 0 1.5rem 0;
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
        position: relative;
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
      .package-subcategory {
        display: inline-block;
        background: #9A4665;
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
      /* === Bandera en esquina superior derecha === */
      .package-flag {
        position: absolute;
        top: 12px;
        right: 12px;
        width: 32px;
        height: 24px;
        border: 1.5px solid #151515;
        border-radius: 0;
        object-fit: cover;
      }
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
      /* === Paginación === */
      .paginacion-wrap {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 1rem;
        margin-top: 2rem;
        padding: 1rem 0;
        border-top: 2px solid #151515;
      }
      .paginacion-wrap .btn {
        border: 2px solid #151515;
        border-radius: 0;
        font-weight: 500;
      }
      .paginacion-info {
        font-weight: 500;
        color: #447099;
      }
      /* === Landing / globo === */
      .landing-wrap {
        padding: 0;
      }
      .landing-cta {
        text-align: center;
        margin-top: 2rem;
        padding: 0 1rem;
      }
      .landing-cta .btn {
        margin: 0 0.5rem 0.5rem 0.5rem;
      }
      /* === Grid de países === */
      .paises-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
        gap: 1rem;
        padding: 1.5rem 0;
      }
      .pais-card {
        background: #FFFFFF;
        border: 2px solid #151515;
        box-shadow: 4px 4px 0 #EAFF38;
        padding: 1.25rem 1rem;
        text-align: center;
        cursor: pointer;
        transition: all 0.15s ease;
        user-select: none;
      }
      .pais-card:hover {
        transform: translateY(-4px);
        box-shadow: 7px 7px 0 #EAFF38;
        border-color: #447099;
      }
      .pais-card:active {
        transform: translateY(0);
        box-shadow: 2px 2px 0 #EAFF38;
      }
      .pais-flag {
        width: 56px;
        height: 42px;
        border: 1.5px solid #151515;
        object-fit: cover;
        display: block;
        margin: 0 auto 0.6rem auto;
      }
      .pais-nombre {
        font-weight: 700;
        font-size: 0.85rem;
        color: #151515;
        margin-bottom: 0.35rem;
        line-height: 1.2;
      }
      .pais-count {
        display: inline-block;
        background: #447099;
        color: #FFFFFF;
        font-size: 0.75rem;
        font-weight: 700;
        padding: 0.15rem 0.5rem;
        border: 1.5px solid #151515;
      }
      /* === Grid de categorías === */
      .categorias-section {
        padding: 2rem 0 1rem 0;
        border-top: 3px solid #151515;
        margin-top: 1rem;
      }
      .categorias-titulo {
        font-size: 1.1rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
        color: #151515;
        margin-bottom: 1rem;
      }
      .categorias-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
        gap: 0.75rem;
      }
      .categoria-card {
        background: #FFFFFF;
        border: 2px solid #151515;
        box-shadow: 3px 3px 0 #EAFF38;
        padding: 0.9rem 0.75rem;
        text-align: center;
        cursor: pointer;
        transition: all 0.15s ease;
        user-select: none;
      }
      .categoria-card:hover {
        transform: translateY(-3px);
        box-shadow: 6px 6px 0 #EAFF38;
        border-color: #447099;
      }
      .categoria-emoji {
        font-size: 1.6rem;
        display: block;
        margin-bottom: 0.3rem;
      }
      .categoria-nombre {
        font-weight: 700;
        font-size: 0.8rem;
        color: #151515;
        margin-bottom: 0.3rem;
        line-height: 1.2;
      }
      .categoria-count {
        display: inline-block;
        background: #419599;
        color: #FFFFFF;
        font-size: 0.7rem;
        font-weight: 700;
        padding: 0.1rem 0.45rem;
        border: 1.5px solid #151515;
      }
      /* Subcategorías */
      .subcategorias-wrap {
        margin-top: 0.75rem;
        padding-top: 0.75rem;
        border-top: 2px dashed #C2C2C4;
      }
      .subcategorias-titulo {
        font-size: 0.75rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        color: #707073;
        margin-bottom: 0.5rem;
      }
      .subcategorias-grid {
        display: flex;
        flex-wrap: wrap;
        gap: 0.5rem;
      }
      .subcategoria-card {
        background: #FFFFFF;
        border: 2px solid #151515;
        box-shadow: 2px 2px 0 #EAFF38;
        padding: 0.5rem 0.7rem;
        text-align: center;
        cursor: pointer;
        transition: all 0.15s ease;
        user-select: none;
        flex: 1;
        min-width: 130px;
      }
      .subcategoria-card:hover {
        transform: translateY(-2px);
        box-shadow: 4px 4px 0 #EAFF38;
        border-color: #447099;
      }
      .subcategoria-emoji {
        font-size: 1.1rem;
        margin-right: 0.3rem;
      }
      .subcategoria-nombre {
        font-weight: 700;
        font-size: 0.78rem;
        color: #151515;
      }
      .subcategoria-count {
        display: inline-block;
        background: #9A4665;
        color: #FFFFFF;
        font-size: 0.65rem;
        font-weight: 700;
        padding: 0.1rem 0.35rem;
        border: 1px solid #151515;
        margin-left: 0.3rem;
      }
      /* === Navset sin card === */
      .navset-landing .nav-tabs {
        border-bottom: 3px solid #151515;
        margin-bottom: 0;
      }
      .navset-landing .nav-link {
        border: 2px solid #151515;
        border-bottom: none;
        border-radius: 0;
        font-weight: 500;
        color: #151515;
        background: #FFFFFF;
      }
      .navset-landing .nav-link.active {
        background: #EAFF38;
        color: #151515;
        border-bottom: 3px solid #EAFF38;
        margin-bottom: -3px;
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

  # Contenedor principal con tabs: Mapa (landing full-width) y Catálogo
  div(
    class = "container-fluid navset-landing",
    style = "margin-top: -20px; padding: 0;",

    navset_tab(
      id = "tab_principal",
      selected = "tab_mapa",
      header = NULL,
      footer = NULL,

      # --- Tab Mapa (landing page full-width) ---
      nav_panel(
        title = tagList(icon("globe"), " Mapa"),
        value = "tab_mapa",

        div(
          class = "landing-wrap",

          # Stats compactas
          div(
            class = "container",
            style = "padding: 1.5rem 0;",
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
            )
          ),

          # Grid de países + grid de categorías
          div(
            class = "container",
            uiOutput("grid_paises"),
            uiOutput("grid_categorias")
          ),

          # CTA para entrar al catálogo
          div(
            class = "landing-cta",
            p(style = "color: #707073; margin-bottom: 1rem;",
              "Hacé clic en un país para ver sus paquetes · o explorá el catálogo completo"),
            actionButton(
              inputId = "ir_catalogo",
              label = "Ver todos los paquetes",
              icon = icon("list"),
              class = "btn-estacion"
            )
          )
        )
      ),

      # --- Tab Catálogo ---
      nav_panel(
        title = tagList(icon("list"), " Catálogo"),
        value = "tab_catalogo",

        div(
          class = "container",
          style = "padding-top: 20px;",

        # Filtros
        div(
          class = "filter-card",
          style = "margin-top: 20px;",
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
                choices = c("Todas" = "", setNames(names(categorias), categorias)),
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
          uiOutput("lista_paquetes"),
          uiOutput("paginacion")
        )
        )  # cierra div.container del catálogo
      )
    ),

    # Footer
    div(
      class = "footer-brand",
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
        "© 2026 Estación R | Todos los paquetes son propiedad de sus respectivos autores")
    )
  )
)

# Server
server <- function(input, output, session) {

  # Verificar que se cargaron los datos
  if (is.null(paquetes)) {
    showModal(modalDialog(
      title = "Error al cargar datos",
      "No se pudieron cargar los paquetes. Por favor, intenta más tarde.",
      easyClose = TRUE,
      footer = NULL
    ))
  }

  CARDS_POR_PAGINA <- 12L
  pagina_actual    <- reactiveVal(1L)

  # Resetear paginación cuando cambian los filtros
  observeEvent(list(input$pais, input$categoria, input$busqueda), {
    pagina_actual(1L)
  }, ignoreInit = TRUE)

  observeEvent(input$pag_ant, {
    pagina_actual(max(1L, pagina_actual() - 1L))
  })

  observeEvent(input$pag_sig, {
    total_pags <- ceiling(nrow(datos_filtrados()) / CARDS_POR_PAGINA)
    pagina_actual(min(total_pags, pagina_actual() + 1L))
  })

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

  # --- Grid de países (landing page) ---

  output$grid_paises <- renderUI({
    req(conteo_paises)

    cards <- lapply(seq_len(nrow(conteo_paises)), function(i) {
      pais_nombre <- conteo_paises$pais[i]
      n           <- conteo_paises$n_paquetes[i]
      flag_src    <- flag_url(pais_nombre)

      div(
        class = "pais-card",
        onclick = sprintf(
          "Shiny.setInputValue('pais_seleccionado', '%s', {priority: 'event'})",
          pais_nombre
        ),
        if (!is.na(flag_src)) {
          tags$img(
            src     = flag_src,
            alt     = pais_nombre,
            class   = "pais-flag",
            loading = "lazy",
            onerror = "this.style.display='none';"
          )
        },
        div(class = "pais-nombre", pais_nombre),
        span(class = "pais-count",
             sprintf("%d paquete%s", n, ifelse(n != 1, "s", "")))
      )
    })

    div(class = "paises-grid", cards)
  })

  # --- Grid de categorías (landing page) ---

  output$grid_categorias <- renderUI({
    req(conteo_categorias)

    # Cards de categorías
    cat_cards <- lapply(seq_len(nrow(conteo_categorias)), function(i) {
      cat_id  <- as.character(conteo_categorias$nro_tematica[i])
      nombre  <- categorias[cat_id]
      if (is.na(nombre)) return(NULL)
      n       <- conteo_categorias$n_paquetes[i]
      emoji   <- categoria_emoji[cat_id]
      if (is.na(emoji)) emoji <- "📦"

      div(
        class = "categoria-card",
        onclick = sprintf(
          "Shiny.setInputValue('categoria_seleccionada', '%s', {priority: 'event'})",
          cat_id
        ),
        span(class = "categoria-emoji", emoji),
        div(class = "categoria-nombre", nombre),
        span(class = "categoria-count",
             sprintf("%d paquete%s", n, ifelse(n != 1, "s", "")))
      )
    })

    div(
      class = "categorias-section",
      div(class = "categorias-titulo", "Por categoría"),
      div(class = "categorias-grid", cat_cards)
    )
  })

  # Click en categoría → filtrar catálogo
  observeEvent(input$categoria_seleccionada, {
    cat_id <- input$categoria_seleccionada
    if (is.null(cat_id) || cat_id == "") return()
    updatePickerInput(session, "categoria", selected = cat_id)
    updatePickerInput(session, "pais", selected = "")
    nav_select("tab_principal", selected = "tab_catalogo")
  })

  # Click en un país del grid → filtrar catálogo y cambiar de tab
  observeEvent(input$pais_seleccionado, {
    pais_click <- input$pais_seleccionado
    if (is.null(pais_click) || pais_click == "") return()

    updatePickerInput(session, "pais", selected = pais_click)
    nav_select("tab_principal", selected = "tab_catalogo")
  })

  # Botón "Ver todos los paquetes" → ir al catálogo sin filtro
  observeEvent(input$ir_catalogo, {
    nav_select("tab_principal", selected = "tab_catalogo")
  })

  # --- Datos filtrados reactivos ---

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

  # Estadísticas (sobre datos completos, no filtrados, para el landing)
  output$total_paquetes <- renderText({
    req(paquetes)
    nrow(paquetes)
  })

  output$total_paises <- renderText({
    req(paquetes)
    n_distinct(paquetes$pais[paquetes$pais != "No especificado"], na.rm = TRUE)
  })

  output$total_categorias <- renderText({
    req(paquetes)
    n_distinct(paquetes$nro_tematica)
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

  # Control de paginación
  output$paginacion <- renderUI({
    req(datos_filtrados())
    total <- nrow(datos_filtrados())
    total_pags <- ceiling(total / CARDS_POR_PAGINA)
    if (total_pags <= 1) return(NULL)

    pag <- pagina_actual()
    div(
      class = "paginacion-wrap",
      actionButton("pag_ant", label = icon("arrow-left"), class = "btn-outline-secondary",
                   disabled = pag == 1),
      span(class = "paginacion-info",
           sprintf("Página %d de %d", pag, total_pags)),
      actionButton("pag_sig", label = icon("arrow-right"), class = "btn-outline-secondary",
                   disabled = pag == total_pags)
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
          icon("search", style = "font-size: 4rem; color: #C2C2C4;"),
          h4("No se encontraron paquetes", style = "color: #707073; margin-top: 20px;"),
          p("Intenta ajustar los filtros de búsqueda")
        )
      )
    }

    # Paginar
    pag  <- pagina_actual()
    ini  <- (pag - 1L) * CARDS_POR_PAGINA + 1L
    fin  <- min(pag * CARDS_POR_PAGINA, nrow(datos))
    datos <- datos[ini:fin, ]

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

        # Bandera del país en esquina superior derecha
        if (!is.na(pkg$pais) && pkg$pais != "" && pkg$pais != "No especificado") {
          flag_src <- flag_url(pkg$pais)
          if (!is.na(flag_src)) {
            tags$img(
              src = flag_src,
              alt = pkg$pais,
              class = "package-flag",
              loading = "lazy",
              onerror = "this.style.display='none';"
            )
          }
        },

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
            icon("cube", style = sprintf(
              "font-size: 2.5rem; color: #447099; margin-right: 15px; display: %s;",
              if (!is.na(pkg$icono) && pkg$icono != "") "none" else "inline-block"
            )),
            div(
              div(class = "package-name", pkg$paquete),
              div(
                span(class = "package-category", categoria_texto),
                if (!is.na(pkg$subcategoria)) {
                  sub_label <- subcategoria_label[pkg$subcategoria]
                  if (!is.na(sub_label)) {
                    span(class = "package-subcategory", sub_label)
                  }
                }
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

    do.call(tagList, tarjetas)
  })
}

# Ejecutar la aplicación
shinyApp(ui = ui, server = server)