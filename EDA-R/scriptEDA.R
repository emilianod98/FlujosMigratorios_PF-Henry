# Carga de data

df_total <- read.csv('total_mundo.csv')
df_expulsores <- read.csv('expulsores.csv')
df_homicidios <- read.csv('homicides100K.csv')
df_receptores <- read.csv('receptores.csv')
df_remesas <- read.csv('remesas.csv')

# Carga de libreria tidyverse

library(tidyverse)

## Analizando Homicidios

# Estructura de la data
head(df_total)    # Muestra las primeras filas del DataFrame
tail(df_total)
str(df_total)     # Proporciona información sobre la estructura de los datos

summary(df_total$Value)    # Resumen estadístico de la columna "Value"

# Graficas de la data
library(ggplot2)
library(dplyr)

# Crea el histograma de la columna 'Tasa por cada 100K' para todos los países
ggplot(df_top5, aes(x = `Tasa por cada 100K`)) +
  geom_histogram(binwidth = 1, fill = "lightblue", color = "black") +
  geom_density(alpha = 0.2, fill = "orange") +
  labs(x = "Tasa por cada 100K", y = "Frecuencia") +
  ggtitle("Distribución de la tasa por cada 100K para todos los países") +
  theme_minimal()

# Calcula la media de la columna 'Tasa por cada 100K'
mean_value <- mean(df_top5$`Tasa por cada 100K`)

# Agrega una línea vertical en la media
geom_vline(xintercept = mean_value, color = "red", linetype = "dashed") +
  geom_text(
    x = mean_value, y = 0, 
    label = paste("Media:", round(mean_value, 2)),
    vjust = 1, hjust = 1.5, color = "red"
  )


