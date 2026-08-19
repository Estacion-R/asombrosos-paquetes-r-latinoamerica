# Asombrosos Paquetes - Aplicación Shiny

Aplicación web interactiva para explorar paquetes de R desarrollados en Latinoamérica.

## Características

- 🔍 **Búsqueda avanzada** por nombre, descripción o autores
- 🌎 **Filtros** por país y categoría
- 📊 **Estadísticas** en tiempo real
- 📦 **Detalles** de cada paquete al hacer clic
- 🔗 **Enlaces directos** a la documentación
- 📱 **Diseño responsive** que funciona en cualquier dispositivo

## Ejecutar localmente

### Requisitos previos

Instalar las librerías necesarias:

```r
install.packages(c("shiny", "tidyverse", "googlesheets4", "DT", "bslib"))
```

### Ejecutar la app

Desde R o RStudio:

```r
# Opción 1: Desde el directorio app/
shiny::runApp()

# Opción 2: Especificando la ruta
shiny::runApp("app/")
```

La aplicación se abrirá en tu navegador predeterminado en `http://127.0.0.1:XXXX`

## Deploy a shinyapps.io

### 1. Crear cuenta

Crear una cuenta gratuita en [shinyapps.io](https://www.shinyapps.io)

### 2. Configurar credenciales

```r
# Instalar rsconnect
install.packages("rsconnect")

# Configurar credenciales (obtenerlas desde tu dashboard de shinyapps.io)
rsconnect::setAccountInfo(
  name = "tu-cuenta",
  token = "TU_TOKEN",
  secret = "TU_SECRET"
)
```

### 3. Deployar

```r
# Desde el directorio raíz del proyecto
rsconnect::deployApp(appDir = "app", appName = "asombrosos-paquetes")
```

### 4. URL de la app

Tu app estará disponible en:
```
https://tu-cuenta.shinyapps.io/asombrosos-paquetes/
```

## Estructura de archivos

```
app/
├── app.R           # Aplicación principal (UI + Server)
├── .gitignore      # Archivos a ignorar en Git
├── README.md       # Esta documentación
└── www/            # Recursos estáticos (opcional)
    └── styles.css  # Estilos personalizados (futuro)
```

## Configuración

### Cache de datos

Para mejorar el rendimiento, puedes implementar cache de los datos del Google Sheet:

```r
library(memoise)

leer_paquetes <- memoise(
  function() {
    gs4_deauth()
    read_sheet(url_sheet)
  },
  ~memoise::timeout(3600)  # Cache de 1 hora
)
```

### Actualización de datos

Los datos se leen directamente del Google Sheet cada vez que la app inicia. Si despliegas en shinyapps.io, la app se reinicia automáticamente después de períodos de inactividad, lo que garantiza datos frescos.

Para forzar una recarga, puedes reiniciar la app desde el dashboard de shinyapps.io.

## Solución de problemas

### Error al leer Google Sheet

Si obtienes error al leer el Google Sheet:
- Verifica que la URL sea correcta
- Asegúrate que el Sheet tenga permisos de lectura pública
- Verifica tu conexión a internet

### Error de paquetes faltantes

Si faltan paquetes al desplegar:
- Asegúrate que todas las librerías estén instaladas
- El archivo `app.R` debe tener todos los `library()` al inicio
- shinyapps.io instalará automáticamente las dependencias

## Mantenimiento

### Actualizar la app

Después de hacer cambios en `app.R`:

```r
rsconnect::deployApp(appDir = "app", appName = "asombrosos-paquetes")
```

### Ver logs

Para ver logs de errores en shinyapps.io:

```r
rsconnect::showLogs(appName = "asombrosos-paquetes")
```

## Soporte

Para reportar problemas o sugerencias, crear un [issue en GitHub](https://github.com/pablotis/asombrosos-paquetes-r-latinoamerica/issues).

---

**Desarrollado por** [Estación R](mailto:pablotisco@gmail.com)
**Licencia**: CC BY 4.0
