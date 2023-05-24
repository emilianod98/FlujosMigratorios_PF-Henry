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

## 

library(ggplot2)

# Crea un histograma de la columna 'Tasa.por.cada.100K'
ggplot(df_top5, aes(x = `Tasa.por.cada.100K`)) +
  geom_histogram(binwidth = 1, fill = "lightblue", color = "black") +
  labs(x = "Tasa por cada 100K", y = "Frecuencia") +
  ggtitle("Distribución de la tasa por cada 100K")

colnames(df_homicidios)

