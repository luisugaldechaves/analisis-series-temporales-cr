# 📊 Analizador de Series Temporales: Inflación y PIB de Costa Rica

## Descripción

Este proyecto presenta una herramienta de análisis econométrico desarrollada en R para el estudio de series temporales de indicadores macroeconómicos clave de Costa Rica: **inflación** y **crecimiento del PIB**. El script automatiza la descarga de datos del Banco Mundial, realiza transformaciones estadísticas avanzadas y genera visualizaciones profesionales para facilitar la interpretación de tendencias económicas.

La herramienta está diseñada con estándares profesionales y puede ser utilizada tanto para investigación académica como para análisis de política económica.

---

## 🎯 Objetivos del Análisis

1. **Extracción automatizada de datos**: Obtención de series históricas del Banco Mundial mediante la API de World Development Indicators (WDI).
2. **Transformaciones estadísticas**: Cálculo de variaciones interanuales, medias móviles y descomposición de series temporales.
3. **Análisis de correlación**: Evaluación de la relación entre inflación y crecimiento económico.
4. **Visualización de datos**: Generación de gráficos de alta calidad utilizando `ggplot2` para comunicar resultados de manera efectiva.

---

## 📦 Requisitos

### Librerías de R

El script requiere las siguientes librerías, que se instalan automáticamente si no están disponibles:

- `WDI` - Para obtener datos del Banco Mundial
- `ggplot2` - Para visualizaciones avanzadas
- `dplyr` - Para manipulación de datos
- `tidyr` - Para transformación de datos
- `lubridate` - Para manejo de fechas
- `scales` - Para formateo de ejes en gráficos
- `stats` - Para análisis estadístico
- `gridExtra` - Para combinar gráficos
- `readr` - Para lectura de archivos CSV
- `zoo` - Para cálculo de medias móviles

### Versión de R

Se recomienda utilizar R versión 4.0 o superior.

---

## 🚀 Instrucciones de Uso

### 1. Clonar o descargar el repositorio
```bash
git clone https://github.com/tu-usuario/analizador-series-temporales-cr.git
cd analizador-series-temporales-cr
```

### 2. Abrir el script en RStudio o R

Abra el archivo `analisis_series_temporales.R` en su entorno de desarrollo preferido.

### 3. Ejecutar el script

El script se puede ejecutar completo desde RStudio o mediante línea de comandos:
```bash
Rscript analisis_series_temporales.R
```

### 4. Resultados

Los gráficos y tablas generadas se guardarán automáticamente en la carpeta `resultados/`:

- **Gráficos PNG**: Visualizaciones de alta resolución (300 DPI)
- **Archivos CSV**: Datos procesados y estadísticas descriptivas

---

## 📈 Análisis Realizados

### 1. **Variación Interanual**

Calcula el cambio en puntos porcentuales de la inflación y el PIB respecto al año anterior. Esta métrica permite identificar aceleraciones o desaceleraciones en los indicadores.

**Fórmula:**
```
Variación_t = Indicador_t - Indicador_{t-1}
```

### 2. **Media Móvil (MA-3)**

Suaviza las fluctuaciones de corto plazo mediante el promedio de tres períodos consecutivos, facilitando la identificación de tendencias subyacentes.

**Fórmula:**
```
MA3_t = (Indicador_{t-2} + Indicador_{t-1} + Indicador_t) / 3
```

### 3. **Descomposición de Series Temporales**

Separa la serie en tres componentes:

- **Tendencia**: Patrón de largo plazo estimado mediante regresión lineal
- **Componente irregular (residuos)**: Desviaciones aleatorias respecto a la tendencia
- **Serie original**: Datos observados sin transformación

Este análisis permite distinguir entre movimientos estructurales y fluctuaciones cíclicas.

### 4. **Análisis de Correlación**

Evalúa la relación lineal entre inflación y crecimiento del PIB mediante el coeficiente de correlación de Pearson, incluyendo pruebas de significancia estadística.

---

## 📊 Interpretación de Resultados

### Gráfico Comparativo

Muestra la evolución temporal de ambos indicadores en una misma escala, permitiendo identificar:
- Períodos de alta/baja inflación
- Fases de expansión/contracción económica
- Posibles relaciones entre ambas variables

**Línea punteada horizontal (y=0)**: Referencia para identificar inflación negativa (deflación) o decrecimiento económico.

### Histograma de Variaciones

Presenta la distribución de las variaciones interanuales de la inflación:
- **Asimetría**: Indica si las aceleraciones inflacionarias son más frecuentes que las desaceleraciones
- **Dispersión**: Muestra la volatilidad del indicador
- **Media (línea vertical)**: Punto de referencia para el cambio promedio

### Descomposición y Residuos

- **Tendencia**: Si es positiva/negativa, indica presión inflacionaria estructural creciente/decreciente
- **Residuos grandes**: Sugieren shocks económicos (crisis, reformas, eventos externos)
- **Residuos pequeños**: Indican comportamiento predecible del indicador

---

## 📁 Estructura del Proyecto
```
analizador-series-temporales-cr/
│
├── analisis_series_temporales.R    # Script principal
├── README.md                        # Documentación del proyecto
└── resultados/                      # Directorio de salidas (creado automáticamente)
    ├── grafico_comparativo.png
    ├── grafico_histograma.png
    ├── grafico_descomposicion.png
    ├── grafico_residuos.png
    ├── panel_descomposicion_completo.png
    ├── datos_procesados.csv
    └── estadisticas_descriptivas.csv
```

---

## 🔄 Uso Alternativo con Datos del BCCR

Si se prefiere utilizar datos del Banco Central de Costa Rica en lugar del Banco Mundial, el script incluye una función para cargar archivos CSV locales.

### Estructura del archivo CSV requerida:

| fecha       | inflacion | pib_crecimiento |
|------------|-----------|-----------------|
| 1994-01-01 | 13.5      | 4.7             |
| 1995-01-01 | 23.2      | 3.9             |
| ...        | ...       | ...             |

### Instrucciones:

1. Coloque su archivo CSV en el directorio del proyecto
2. Modifique la línea 97 del script:
```r
datos_cr <- cargar_datos_csv("nombre_de_su_archivo.csv")
```

3. Comente la sección de descarga de WDI (líneas 69-82)

---

## 📚 Referencias Técnicas

- **World Development Indicators (WDI)**: Base de datos del Banco Mundial con indicadores macroeconómicos de 217 economías. [Documentación oficial](https://datatopics.worldbank.org/world-development-indicators/)
- **Descomposición de series temporales**: Técnica estadística para separar componentes de tendencia, estacionalidad y aleatoriedad (Brockwell & Davis, 2016)
- **Media móvil**: Método de suavizado para filtrar ruido en series temporales (Hamilton, 1994)

---

## 🎓 Aplicaciones Académicas

Esta herramienta es ideal para:

- **Trabajos de investigación**: Análisis empírico de fenómenos macroeconómicos
- **Tesis de grado**: Componente técnico para estudios econométricos
- **Portafolio profesional**: Demostración de habilidades en análisis de datos y programación
- **Presentaciones académicas**: Generación rápida de visualizaciones profesionales

---

## 👤 Autor

Luis Armando Ugalde Chaves

---

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.



**Última actualización**: Febrero 2026
