# Plan de trabajo — Catálogo de Paquetes R

**Inicio:** 2026-08-19
**Estado:** En ejecución

---

## Fase 1 — Datos (desbloquea todo lo demás)

### 1.1 Exportar Google Sheet → `data/paquetes.yaml`
- Script R que lee el Sheet con `gs4_deauth()` y escribe el YAML
- Mapeo de columnas: `nro_tematica→categoria`, `paquete→nombre`, `link→url`, `autor_es→autores`, `icono→hexlogo`
- Agregar campo `vigente: true` a todos por defecto
- **Output:** `data/paquetes.yaml` completo con todos los paquetes

### 1.2 Validar el YAML
- Verificar que todos los campos requeridos están presentes
- Chequear URLs activas (muestra de 10)
- Commit + push

---

## Fase 2 — App: leer desde YAML

### 2.1 Actualizar `app/app.R`
- Reemplazar `read_sheet()` por `yaml::read_yaml()` + limpieza
- Normalizar nombres de columna para que coincidan con los filtros actuales
- Sin cambios en UI ni en lógica de filtrado

### 2.2 Test local
- Correr `ejecutar_app.R` y verificar filtros, tarjetas, búsqueda
- Commit + push

---

## Fase 3 — Deploy a Posit Connect Cloud

- Confirmar cuenta activa `pablotiscornia@estacion-r.com`
- Configurar credenciales con `rsconnect::setAccountInfo()`
- `rsconnect::deployApp(appDir = "app")` apuntando a Connect Cloud
- Verificar URL pública
- Agregar link en README

---

## Fase 4 — Automatización: issue → PR automático

Cuando un issue recibe label `aprobado`:
- Action que parsea los campos del issue
- Crea rama `paquete/<nombre>`
- Agrega entrada al YAML
- Abre PR con descripción y referencia al issue

Requiere: Fase 1 completada (datos en YAML).

---

## Fase 5 — Discussions

- Habilitar Discussions en GitHub repo settings
- Verificar que el link del Issue template config funciona

---

## Mapping de columnas Sheet → YAML

| Google Sheet    | YAML        | Notas                        |
|----------------|-------------|------------------------------|
| nro_tematica   | categoria   | entero 1-8                   |
| paquete        | nombre      |                              |
| link           | url         |                              |
| descripcion    | descripcion |                              |
| autor_es       | autores     |                              |
| icono          | hexlogo     | puede ser NA → omitir        |
| pais           | pais        |                              |
| —              | vigente     | agregar `true` a todos       |
