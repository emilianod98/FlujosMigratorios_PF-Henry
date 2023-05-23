-   **Mostramos un analisis exploratorio de los datos de las tablas
    extraidas para los KPIs sugeridos**

# Carga de data

    df_total <- read.csv('total_mundo.csv')
    df_expulsores <- read.csv('expulsores.csv')
    df_homicidios <- read.csv('homicides100K.csv')
    df_receptores <- read.csv('receptores.csv')
    df_remesas <- read.csv('remesas.csv')

# Tabla de Homicidios

    head(df_homicidios,3)

    ##   Country.Name Country.Code Year Homicides Poblacion Tasa.por.cada.100K
    ## 1  Afghanistan          AFG 2007      3657  25903301           14.11789
    ## 2  Afghanistan          AFG 2008      3785  26427199           14.32237
    ## 3  Afghanistan          AFG 2009      3874  27385307           14.14627

## Resumen del dataframe de Homicidios

    summary(df_homicidios)

    ##  Country.Name       Country.Code            Year        Homicides       
    ##  Length:6150        Length:6150        Min.   :1990   Min.   :     0.0  
    ##  Class :character   Class :character   1st Qu.:1997   1st Qu.:    41.0  
    ##  Mode  :character   Mode  :character   Median :2004   Median :   273.0  
    ##                                        Mean   :2004   Mean   :  4151.5  
    ##                                        3rd Qu.:2012   3rd Qu.:   885.8  
    ##                                        Max.   :2019   Max.   :463129.0  
    ##                                                                         
    ##    Poblacion         Tasa.por.cada.100K
    ##  Min.   :0.000e+00   Min.   :0.000     
    ##  1st Qu.:1.025e+06   1st Qu.:1.938     
    ##  Median :5.746e+06   Median :4.944     
    ##  Mean   :3.164e+07   Mean   :  Inf     
    ##  3rd Qu.:2.007e+07   3rd Qu.:9.756     
    ##  Max.   :1.408e+09   Max.   :  Inf     
    ##                      NA's   :90

## Valores Nulos

    apply(X = is.na(df_homicidios), MARGIN = 2, FUN = sum)

    ##       Country.Name       Country.Code               Year          Homicides 
    ##                  0                  0                  0                  0 
    ##          Poblacion Tasa.por.cada.100K 
    ##                  0                 90

## Valores Duplicados

    sum(duplicated(df_homicidios))

    ## [1] 0

### Para nuestro analisis eliminares los valores ‘inf’ segun la columna ‘Tasa.por.cada.100K’

    # Eliminar filas con valor 'Inf' en una columna específica
    df_homicidios_sin_inf <- subset(df_homicidios, is.finite(df_homicidios$Tasa.por.cada.100K))

## Promedio de la tasa de homicidios

    # Imprimir el nuevo DataFrame sin las filas que contienen 'Inf'
    promedio <- mean(df_homicidios_sin_inf$Tasa.por.cada.100K)
    promedio

    ## [1] 8.090187

## Histograma de la columna ‘Tasa.por.cada.100K’

    library(ggplot2)

    # Calcula la media de la columna 'Tasa.por.cada.100K'
    mean_value <- mean(df_homicidios$Tasa.por.cada.100K)

    # Crea un histograma de la columna 'Tasa.por.cada.100K' con línea para la media
    ggplot(df_homicidios, aes(x = Tasa.por.cada.100K)) +
      geom_histogram(binwidth = 1, fill = "lightblue", color = "black") +
      geom_vline(xintercept = mean_value, color = "red", linetype = "dashed") +
      labs(x = "Tasa por cada 100K", y = "Frecuencia") +
      ggtitle("Distribución de la tasa por cada 100K") +
      annotate("text", x = mean_value, y = 10, label = "Media", color = "red")

![](ReporteEDA_files/figure-markdown_strict/unnamed-chunk-8-1.png)

## Correlacion entre cantidad de Homicidios y Poblacion

    library(ggplot2)
    ggplot(df_homicidios, aes(x = Poblacion, y = Homicides)) +
      geom_point() +
      xlab("Poblacion") +
      ylab("Homicides")

![](ReporteEDA_files/figure-markdown_strict/unnamed-chunk-9-1.png)

-   Se aprecia que no existe una aparente correlacion entre ambas
    variables

## Diagrama de Cajas

    library(ggplot2)

    ggplot(df_homicidios, aes(x = "", y = Tasa.por.cada.100K)) +
      geom_boxplot(fill = "lightblue", color = "black") +
      ylab("Tasa por cada 100K") +
      xlab("") +
      ggtitle("Diagrama de Cajas de Tasa por cada 100K") +
      scale_y_continuous(breaks = seq(0, 100, by = 5))

![](ReporteEDA_files/figure-markdown_strict/unnamed-chunk-10-1.png)

# Tabla de Remesas

    head(df_remesas,3)

    ##   Country.Name Country.Code Year Value
    ## 1  Afghanistan          AFG 1960    NA
    ## 2  Afghanistan          AFG 1961    NA
    ## 3  Afghanistan          AFG 1962    NA

## Resumen Remesas

    summary(df_remesas)

    ##  Country.Name       Country.Code            Year          Value          
    ##  Length:16492       Length:16492       Min.   :1960   Min.   :0.000e+00  
    ##  Class :character   Class :character   1st Qu.:1975   1st Qu.:2.145e+07  
    ##  Mode  :character   Mode  :character   Median :1990   Median :1.980e+08  
    ##                                        Mean   :1990   Mean   :7.055e+09  
    ##                                        3rd Qu.:2006   3rd Qu.:1.771e+09  
    ##                                        Max.   :2021   Max.   :4.608e+11  
    ##                                                       NA's   :7584

## Remesa mayor a que Pais pertenece

    # Encontrar el valor máximo de una columna
    max(df_remesas$Value, na.rm = TRUE)

    ## [1] 460844649359

## Menores Remesas a que Pais Pertenece

    min(df_remesas$Value, na.rm = TRUE)

    ## [1] 0
