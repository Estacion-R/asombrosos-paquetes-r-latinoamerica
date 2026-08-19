# Deploy — Catálogo de Paquetes R

## Posit Connect Cloud (producción)

**URL cuenta:** https://connect.posit.cloud  
**Cuenta:** pablotiscornia  
**Email:** pablotiscornia@estacion-r.com

### Deploy automático (GitHub Actions)

El workflow `.github/workflows/deploy_connect.yml` se dispara automáticamente al pushear cambios en `app/` o `data/paquetes.yaml` a la rama `main`.

**Setup inicial — agregar el API Key como secreto del repo:**

1. Ir a `connect.posit.cloud` → Settings → API Keys → **New API Key**
2. Copiá el key generado
3. Ir al repo: `github.com/Estacion-R/asombrosos-paquetes-r-latinoamerica`
4. Settings → Secrets and variables → Actions → **New repository secret**
   - Name: `CONNECT_API_KEY`
   - Value: el key copiado en el paso 2
5. Pusheá cualquier cambio a `main` → el Action hace el deploy

### Deploy manual desde R (primera vez o debug)

```r
# 1. Instalar rsconnect si no lo tenés
install.packages("rsconnect")

# 2. Agregar el servidor
rsconnect::addServer(
  url  = "https://connect.posit.cloud",
  name = "posit.cloud"
)

# 3. Conectar con API Key (reemplazá TU_API_KEY)
rsconnect::connectApiUser(
  account = "pablotiscornia",
  server  = "posit.cloud",
  apiKey  = "TU_API_KEY"
)

# 4. Deploy (desde la raíz del proyecto)
rsconnect::deployApp(
  appDir  = "app",
  server  = "posit.cloud",
  account = "pablotiscornia",
  appName = "catalogo-paquetes-r"
)
```

### Actualizar paquetes en el catálogo

Los datos viven en `data/paquetes.yaml`. Para agregar un paquete manualmente:
1. Editá `data/paquetes.yaml`
2. Commit + push a `main`
3. El Action de deploy se dispara automáticamente

El flujo de issues (propuestas de la comunidad) también actualiza el YAML via PR.
