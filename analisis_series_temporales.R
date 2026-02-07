# ==============================================================================
# ANALIZADOR DE SERIES TEMPORALES: INFLACIÓN Y PIB DE COSTA RICA
# ==============================================================================
# Autor: Análisis Econométrico
# Descripción: Script para análisis de series temporales de indicadores 
#              macroeconómicos de Costa Rica utilizando datos del Banco Mundial
# Fecha: Febrero 2026
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. CONFIGURACIÓN INICIAL Y CARGA DE LIBRERÍAS
# ------------------------------------------------------------------------------

# Instalación automática de librerías necesarias (si no están instaladas)
paquetes_requeridos <- c("WDI", "ggplot2", "dplyr", "tidyr", "lubridate", 
                         "scales", "stats", "gridExtra", "readr")

paquetes_faltantes <- paquetes_requeridos[!(paquetes_requeridos %in% 
                                              installed.packages()[,"Package"])]

if(length(paquetes_faltantes) > 0) {
  install.packages(paquetes_faltantes, dependencies = TRUE)
}

# Carga de librerías
library(WDI)        # Para obtener datos del Banco Mundial
library(ggplot2)    # Para visualizaciones avanzadas
library(dplyr)      # Para manipulación de datos
library(tidyr)      # Para transformación de datos
library(lubridate)  # Para manejo de fechas
library(scales)     # Para formateo de ejes
library(stats)      # Para análisis estadístico
library(gridExtra)  # Para combinar gráficos
library(readr)      # Para leer archivos CSV (alternativa)

# Configuración de opciones globales
options(scipen = 999)  # Desactivar notación científica
theme_set(theme_minimal())  # Tema predeterminado para gráficos

# ------------------------------------------------------------------------------
# 2. OBTENCIÓN DE DATOS DEL BANCO MUNDIAL
# ------------------------------------------------------------------------------

cat("Descargando datos del Banco Mundial...\n")

# Definición de indicadores del Banco Mundial
# FP.CPI.TOTL.ZG: Inflación, índice de precios al consumidor (% anual)
# NY.GDP.MKTP.KD.ZG: Crecimiento del PIB (% anual)

indicadores <- c(
  inflacion = "FP.CPI.TOTL.ZG",
  pib_crecimiento = "NY.GDP.MKTP.KD.ZG"
)

# Descarga de datos (últimos 30 años para tener suficiente información)
datos_cr <- WDI(
  country = "CR",           # Código ISO de Costa Rica
  indicator = indicadores,
  start = 1994,
  end = 2024,
  extra = FALSE,
  cache = NULL
)

# Verificación de datos descargados
if(nrow(datos_cr) == 0) {
  stop("Error: No se pudieron descargar datos del Banco Mundial.")
}

cat("Datos descargados exitosamente.\n")

# ------------------------------------------------------------------------------
# 3. FUNCIÓN ALTERNATIVA: CARGA DE DATOS DESDE CSV (BCCR)
# ------------------------------------------------------------------------------

# Función para cargar datos desde archivos CSV del BCCR
# Estructura esperada: columnas 'fecha', 'inflacion', 'pib_crecimiento'

cargar_datos_csv <- function(ruta_archivo) {
  tryCatch({
    datos <- read_csv(ruta_archivo, 
                      col_types = cols(
                        fecha = col_date(format = "%Y-%m-%d"),
                        inflacion = col_double(),
                        pib_crecimiento = col_double()
                      ))
    
    # Convertir a formato compatible
    datos <- datos %>%
      mutate(year = year(fecha)) %>%
      select(year, inflacion, pib_crecimiento)
    
    return(datos)
  }, error = function(e) {
    stop(paste("Error al cargar el archivo CSV:", e$message))
  })
}

# Descomentar la siguiente línea para usar datos desde CSV:
# datos_cr <- cargar_datos_csv("datos_bccr.csv")

# ------------------------------------------------------------------------------
# 4. LIMPIEZA Y PREPARACIÓN DE DATOS
# ------------------------------------------------------------------------------

cat("Procesando y limpiando datos...\n")

# Renombrar y organizar columnas
datos_procesados <- datos_cr %>%
  select(year, inflacion, pib_crecimiento) %>%
  arrange(year) %>%
  # Eliminar valores faltantes
  filter(!is.na(inflacion) | !is.na(pib_crecimiento))

# Crear objeto de serie temporal para inflación
ts_inflacion <- ts(datos_procesados$inflacion, 
                   start = min(datos_procesados$year, na.rm = TRUE), 
                   frequency = 1)

# Crear objeto de serie temporal para PIB
ts_pib <- ts(datos_procesados$pib_crecimiento, 
             start = min(datos_procesados$year, na.rm = TRUE), 
             frequency = 1)

# ------------------------------------------------------------------------------
# 5. CÁLCULOS ESTADÍSTICOS Y TRANSFORMACIONES
# ------------------------------------------------------------------------------

cat("Realizando análisis estadístico...\n")

# 5.1 Variación interanual de la inflación
datos_procesados <- datos_procesados %>%
  mutate(
    # Variación interanual (cambio porcentual respecto al año anterior)
    inflacion_var_interanual = inflacion - lag(inflacion, 1),
    pib_var_interanual = pib_crecimiento - lag(pib_crecimiento, 1)
  )

# 5.2 Media móvil de la inflación (ventana de 3 años)
datos_procesados <- datos_procesados %>%
  mutate(
    inflacion_ma3 = zoo::rollmean(inflacion, k = 3, fill = NA, align = "right"),
    pib_ma3 = zoo::rollmean(pib_crecimiento, k = 3, fill = NA, align = "right")
  )

# 5.3 Descomposición de la serie temporal de inflación
# Nota: Para descomposición clásica necesitamos frecuencia > 1
# Como tenemos datos anuales, realizamos análisis de tendencia alternativo

# Cálculo de tendencia mediante regresión lineal
modelo_tendencia_inflacion <- lm(inflacion ~ year, data = datos_procesados)
datos_procesados$inflacion_tendencia <- predict(modelo_tendencia_inflacion)
datos_procesados$inflacion_residuo <- datos_procesados$inflacion - 
  datos_procesados$inflacion_tendencia

# Para PIB
modelo_tendencia_pib <- lm(pib_crecimiento ~ year, data = datos_procesados)
datos_procesados$pib_tendencia <- predict(modelo_tendencia_pib)
datos_procesados$pib_residuo <- datos_procesados$pib_crecimiento - 
  datos_procesados$pib_tendencia

# 5.4 Estadísticas descriptivas
estadisticas_inflacion <- data.frame(
  Indicador = "Inflación",
  Media = mean(datos_procesados$inflacion, na.rm = TRUE),
  Mediana = median(datos_procesados$inflacion, na.rm = TRUE),
  Desv_Std = sd(datos_procesados$inflacion, na.rm = TRUE),
  Min = min(datos_procesados$inflacion, na.rm = TRUE),
  Max = max(datos_procesados$inflacion, na.rm = TRUE)
)

estadisticas_pib <- data.frame(
  Indicador = "Crecimiento PIB",
  Media = mean(datos_procesados$pib_crecimiento, na.rm = TRUE),
  Mediana = median(datos_procesados$pib_crecimiento, na.rm = TRUE),
  Desv_Std = sd(datos_procesados$pib_crecimiento, na.rm = TRUE),
  Min = min(datos_procesados$pib_crecimiento, na.rm = TRUE),
  Max = max(datos_procesados$pib_crecimiento, na.rm = TRUE)
)

estadisticas_resumen <- rbind(estadisticas_inflacion, estadisticas_pib)

# Imprimir estadísticas
cat("\n=== ESTADÍSTICAS DESCRIPTIVAS ===\n")
print(estadisticas_resumen %>% mutate(across(where(is.numeric), ~round(., 2))))

# ------------------------------------------------------------------------------
# 6. VISUALIZACIONES CON GGPLOT2
# ------------------------------------------------------------------------------

cat("\nGenerando visualizaciones...\n")

# 6.1 Gráfico comparativo de series temporales (Inflación y PIB)
grafico_comparativo <- ggplot(datos_procesados, aes(x = year)) +
  geom_line(aes(y = inflacion, color = "Inflación"), linewidth = 1) +
  geom_line(aes(y = pib_crecimiento, color = "Crecimiento PIB"), linewidth = 1) +
  geom_line(aes(y = inflacion_ma3, color = "Inflación (MA-3)"), 
            linewidth = 0.8, linetype = "dashed", alpha = 0.7) +
  geom_hline(yintercept = 0, linetype = "dotted", color = "gray30") +
  scale_color_manual(
    name = "Indicador",
    values = c(
      "Inflación" = "#E74C3C",
      "Crecimiento PIB" = "#3498DB",
      "Inflación (MA-3)" = "#E67E22"
    )
  ) +
  labs(
    title = "Evolución de Inflación y Crecimiento del PIB en Costa Rica",
    subtitle = paste0("Período ", min(datos_procesados$year), "-", 
                      max(datos_procesados$year)),
    x = "Año",
    y = "Porcentaje (%)",
    caption = "Fuente: Banco Mundial (World Development Indicators)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5, color = "gray40"),
    legend.position = "bottom",
    panel.grid.minor = element_blank(),
    plot.caption = element_text(size = 8, color = "gray50", hjust = 1)
  ) +
  scale_x_continuous(breaks = seq(min(datos_procesados$year), 
                                  max(datos_procesados$year), by = 5))

# 6.2 Histograma de distribución de variaciones interanuales de inflación
grafico_histograma <- ggplot(datos_procesados %>% 
                               filter(!is.na(inflacion_var_interanual)), 
                             aes(x = inflacion_var_interanual)) +
  geom_histogram(aes(y = after_stat(density)), 
                 bins = 15, 
                 fill = "#E74C3C", 
                 color = "white", 
                 alpha = 0.7) +
  geom_density(color = "#C0392B", linewidth = 1) +
  geom_vline(xintercept = mean(datos_procesados$inflacion_var_interanual, 
                               na.rm = TRUE), 
             linetype = "dashed", 
             color = "#2C3E50", 
             linewidth = 1) +
  labs(
    title = "Distribución de Variaciones Interanuales de la Inflación",
    subtitle = "Costa Rica: Cambios año a año",
    x = "Variación Interanual (puntos porcentuales)",
    y = "Densidad",
    caption = "Línea vertical: media de variaciones"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13, hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray40"),
    plot.caption = element_text(size = 8, color = "gray50", hjust = 1)
  )

# 6.3 Gráfico de descomposición: Serie original vs Tendencia
grafico_descomposicion <- ggplot(datos_procesados, aes(x = year)) +
  geom_line(aes(y = inflacion, color = "Serie Original"), linewidth = 0.8) +
  geom_line(aes(y = inflacion_tendencia, color = "Tendencia"), 
            linewidth = 1.2) +
  scale_color_manual(
    name = "",
    values = c(
      "Serie Original" = "#95A5A6",
      "Tendencia" = "#E74C3C"
    )
  ) +
  labs(
    title = "Descomposición de la Serie Temporal: Inflación",
    subtitle = "Serie original y tendencia lineal",
    x = "Año",
    y = "Inflación (%)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13, hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray40"),
    legend.position = "bottom"
  )

# 6.4 Gráfico de residuos de la descomposición
grafico_residuos <- ggplot(datos_procesados, aes(x = year, y = inflacion_residuo)) +
  geom_col(fill = "#3498DB", alpha = 0.7) +
  geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  labs(
    title = "Residuos de la Tendencia Lineal - Inflación",
    subtitle = "Desviaciones respecto a la tendencia",
    x = "Año",
    y = "Residuo (%)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13, hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray40")
  )

# ------------------------------------------------------------------------------
# 7. EXPORTACIÓN DE GRÁFICOS Y RESULTADOS
# ------------------------------------------------------------------------------

cat("Guardando gráficos...\n")

# Crear directorio de salida si no existe
if(!dir.exists("resultados")) {
  dir.create("resultados")
}

# Guardar gráficos individuales
ggsave("resultados/grafico_comparativo.png", grafico_comparativo, 
       width = 12, height = 7, dpi = 300)
ggsave("resultados/grafico_histograma.png", grafico_histograma, 
       width = 10, height = 6, dpi = 300)
ggsave("resultados/grafico_descomposicion.png", grafico_descomposicion, 
       width = 12, height = 6, dpi = 300)
ggsave("resultados/grafico_residuos.png", grafico_residuos, 
       width = 12, height = 6, dpi = 300)

# Panel combinado de descomposición
panel_descomposicion <- grid.arrange(
  grafico_descomposicion, 
  grafico_residuos, 
  ncol = 1
)

ggsave("resultados/panel_descomposicion_completo.png", panel_descomposicion, 
       width = 12, height = 10, dpi = 300)

# Exportar datos procesados a CSV
write_csv(datos_procesados, "resultados/datos_procesados.csv")
write_csv(estadisticas_resumen, "resultados/estadisticas_descriptivas.csv")

# ------------------------------------------------------------------------------
# 8. ANÁLISIS DE CORRELACIÓN
# ------------------------------------------------------------------------------

cat("\n=== ANÁLISIS DE CORRELACIÓN ===\n")

# Correlación entre inflación y crecimiento del PIB
correlacion <- cor(datos_procesados$inflacion, 
                   datos_procesados$pib_crecimiento, 
                   use = "complete.obs")

cat(paste0("Correlación entre Inflación y Crecimiento del PIB: ", 
           round(correlacion, 4), "\n"))

# Test de correlación
test_correlacion <- cor.test(datos_procesados$inflacion, 
                             datos_procesados$pib_crecimiento)

cat(paste0("p-valor: ", round(test_correlacion$p.value, 4), "\n"))
cat(paste0("Intervalo de confianza 95%: [", 
           round(test_correlacion$conf.int[1], 4), ", ", 
           round(test_correlacion$conf.int[2], 4), "]\n"))

# ------------------------------------------------------------------------------
# 9. MOSTRAR GRÁFICOS EN PANTALLA
# ------------------------------------------------------------------------------

cat("\nMostrando gráficos...\n")

# Mostrar gráfico comparativo principal
print(grafico_comparativo)

# Pausa para ver el gráfico (comentar si se ejecuta en modo batch)
# readline(prompt = "Presione Enter para ver el siguiente gráfico...")

# Mostrar histograma
print(grafico_histograma)

# Mostrar panel de descomposición
print(panel_descomposicion)

# ------------------------------------------------------------------------------
# 10. RESUMEN FINAL
# ------------------------------------------------------------------------------

cat("\n==============================================================================\n")
cat("ANÁLISIS COMPLETADO EXITOSAMENTE\n")
cat("==============================================================================\n")
cat(paste0("Total de observaciones: ", nrow(datos_procesados), "\n"))
cat(paste0("Período analizado: ", min(datos_procesados$year), "-", 
           max(datos_procesados$year), "\n"))
cat("\nArchivos generados en el directorio 'resultados/':\n")
cat("  - grafico_comparativo.png\n")
cat("  - grafico_histograma.png\n")
cat("  - grafico_descomposicion.png\n")
cat("  - grafico_residuos.png\n")
cat("  - panel_descomposicion_completo.png\n")
cat("  - datos_procesados.csv\n")
cat("  - estadisticas_descriptivas.csv\n")
cat("==============================================================================\n")

# FIN DEL SCRIPT