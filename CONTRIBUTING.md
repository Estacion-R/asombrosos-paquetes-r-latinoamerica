# Cómo contribuir

¡Toda persona es bienvenida a contribuir, sin importar si estás empezando en R o ya tenés experiencia!

## Criterios de inclusión

Un paquete entra al catálogo si cumple **todos** estos requisitos:

- ✅ Es de código abierto (licencia libre)
- ✅ Está disponible para instalar (CRAN, GitHub u otro)
- ✅ Tiene documentación accesible
- ✅ Fue desarrollado por alguien de Latinoamérica (o el equipo principal incluye personas latinoamericanas)

## Cómo proponer un paquete

### Opción 1: GitHub Issue ⭐ La más fácil

1. Abrí un [nuevo issue](https://github.com/Estacion-R/asombrosos-paquetes-r-latinoamerica/issues/new/choose)
2. Elegí la plantilla **"📦 Proponer un paquete"**
3. Completá los campos y enviá

Recibirás una confirmación automática. Revisamos las propuestas todos los lunes.

### Opción 2: Pull Request

1. Editá [`data/paquetes.yaml`](data/paquetes.yaml) agregando una entrada nueva siguiendo el esquema de abajo
2. Abrí un PR con el título `feat: agregar [nombre-del-paquete]`

## Esquema del YAML

Cada paquete tiene la siguiente estructura en `data/paquetes.yaml`:

```yaml
- nombre: nombre_del_paquete
  url: https://url-de-documentacion.com
  descripcion: Descripción breve en español (1–2 oraciones).
  autor: Nombre Apellido
  pais: Argentina         # nombre en español
  categoria: 1            # número de categoría (ver tabla abajo)
  hexlogo: https://url-del-hexlogo.png   # opcional
  vigente: true
```

## Categorías disponibles

| # | Categoría |
|---|-----------|
| 1 | Datos Oficiales |
| 2 | Datos Espaciales |
| 4 | Tratamiento de Datos |
| 5 | Modelado |
| 6 | Visualización |
| 7 | Datasets |
| 8 | Enseñanza |
| 9 | Política y Elecciones |
| 10 | Clima y Meteorología |
| 11 | Economía |
| 12 | Bioinformática |

Si tu paquete no encaja en ninguna categoría, proponé una nueva en el issue o PR.

## Tiempos de revisión

Revisamos propuestas semanalmente (los lunes). Recibirás una respuesta dentro de los 7 días.

## Código de conducta

Seguimos el [Código de Conducta de la comunidad R](https://www.r-project.org/coc.html). Comunicación respetuosa y constructiva siempre.
