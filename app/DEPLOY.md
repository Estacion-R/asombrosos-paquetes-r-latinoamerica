# Guía de Deployment - Asombrosos Paquetes Shiny App

Esta guía te ayudará a desplegar la aplicación Shiny en shinyapps.io paso a paso.

## Pre-requisitos

- [ ] Cuenta en [shinyapps.io](https://www.shinyapps.io) (gratis hasta 5 aplicaciones)
- [ ] R y RStudio instalados
- [ ] Todas las librerías instaladas (ver README.md)

---

## Paso 1: Crear cuenta en shinyapps.io

1. Ir a https://www.shinyapps.io
2. Hacer clic en "Sign Up"
3. Elegir plan gratuito (Free)
4. Completar registro

---

## Paso 2: Obtener credenciales

1. Iniciar sesión en shinyapps.io
2. Ir a **Account** → **Tokens**
3. Hacer clic en **Show** en el token existente (o crear uno nuevo)
4. Copiar el código que aparece, se verá así:

```r
rsconnect::setAccountInfo(name='tu-nombre',
                          token='XXXXXXXXX',
                          secret='XXXXXXXXX')
```

---

## Paso 3: Configurar R/RStudio

Abrir R o RStudio y ejecutar:

```r
# 1. Instalar rsconnect si no lo tienes
install.packages("rsconnect")

# 2. Cargar librería
library(rsconnect)

# 3. Pegar el código copiado de shinyapps.io
rsconnect::setAccountInfo(
  name = 'tu-nombre',
  token = 'XXXXXXXXX',
  secret = 'XXXXXXXXX'
)

# Verificar que quedó configurado
rsconnect::accounts()
```

---

## Paso 4: Probar la app localmente

Antes de desplegar, prueba que funcione localmente:

```r
# Navegar al directorio app/
setwd("app/")

# Ejecutar script de prueba
source("test_app.R")

# O ejecutar directamente
shiny::runApp()
```

Si la app funciona correctamente en tu navegador, puedes continuar.

---

## Paso 5: Desplegar a shinyapps.io

Desde R/RStudio (en el directorio raíz del proyecto):

```r
# Opción 1: Desde la consola
rsconnect::deployApp(
  appDir = "app",
  appName = "asombrosos-paquetes",
  account = "tu-nombre"
)

# Opción 2: Desde RStudio
# Abre app/app.R y haz clic en el botón "Publish" (arriba a la derecha)
```

El proceso tomará unos minutos. Verás mensajes como:

```
Preparing to deploy application...
Uploading bundle for application: XXXXX
Deploying bundle: XXXXX
Waiting for task: XXXXX
Building R package: shiny (X.X.X)
...
Application successfully deployed to https://tu-nombre.shinyapps.io/asombrosos-paquetes/
```

---

## Paso 6: Verificar deployment

1. Abrir la URL que aparece al final del deployment
2. Verificar que:
   - [ ] La app carga correctamente
   - [ ] Se muestran los paquetes
   - [ ] Los filtros funcionan
   - [ ] Los links a documentación funcionan
   - [ ] El botón "Contribuir" abre GitHub

---

## Paso 7: Configurar opciones (opcional)

En el dashboard de shinyapps.io puedes configurar:

### Ajustar recursos

Settings → General:
- **Instance Size**: Small (suficiente para esta app)
- **Max Worker Processes**: 1 (plan gratuito)
- **Max Connections**: 50 (plan gratuito)

### Configurar sleep time

Settings → Advanced:
- **Idle Timeout**: 15 minutos (la app se duerme después de inactividad)
- La app despierta automáticamente cuando alguien la visita

### Logs

Para ver logs de errores:

```r
rsconnect::showLogs(
  appName = "asombrosos-paquetes",
  account = "tu-nombre"
)
```

---

## Actualizar la app

Cuando hagas cambios en `app.R`:

```r
# Re-desplegar
rsconnect::deployApp(
  appDir = "app",
  appName = "asombrosos-paquetes"
)
```

---

## Límites del plan gratuito

El plan gratuito de shinyapps.io incluye:

- ✅ 5 aplicaciones
- ✅ 25 horas activas al mes
- ✅ 1 GB de RAM por app
- ⚠️ La app se duerme después de 15 min de inactividad
- ⚠️ Tiempo de carga inicial puede ser lento

Para mayor performance, considera:
- Plan Starter ($9/mes): 500 horas, sin sleep
- Plan Basic ($39/mes): 2000 horas, más recursos

---

## Solución de problemas

### Error: "Application deployment failed"

**Causas comunes**:
1. Paquetes no instalados en shinyapps.io
2. Código con errores
3. Credenciales incorrectas

**Solución**:
```r
# Ver logs detallados
rsconnect::showLogs(appName = "asombrosos-paquetes")
```

### Error: "Could not connect to Google Sheets"

**Solución**:
- Verificar que el Google Sheet sea público
- Verificar la URL del Sheet en app.R
- Verificar que `gs4_deauth()` esté antes de `read_sheet()`

### App muy lenta

**Soluciones**:
1. Implementar cache (ver README.md)
2. Reducir frecuencia de lectura del Google Sheet
3. Upgrade a plan pago

### App no actualiza datos

**Causa**: La app cachea datos o no se reinició

**Solución**:
1. En dashboard de shinyapps.io: **Restart Application**
2. O re-desplegar con `deployApp()`

---

## URLs Importantes

- **Dashboard**: https://www.shinyapps.io/admin/#/dashboard
- **Documentación**: https://docs.posit.co/shinyapps.io/
- **Soporte**: https://support.posit.co/

---

## Checklist final

Antes de compartir la app públicamente:

- [ ] App funciona correctamente
- [ ] Datos se cargan desde Google Sheet
- [ ] Todos los filtros funcionan
- [ ] Links externos funcionan
- [ ] Diseño responsive (probar en móvil)
- [ ] Actualizado README.md del proyecto con link a la app
- [ ] URL compartida en redes sociales / comunidad

---

## Próximos pasos

Una vez desplegada exitosamente:

1. **Actualizar README.md** del repositorio principal con link a la app
2. **Compartir** en redes sociales (#RStats, #LatinR)
3. **Monitorear** uso desde dashboard de shinyapps.io
4. **Iterar** basado en feedback de usuarios

---

**¿Problemas?** Abre un [issue en GitHub](https://github.com/pablotis/asombrosos-paquetes-r-latinoamerica/issues)
