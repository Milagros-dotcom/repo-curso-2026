sink("tarea03.txt", split = TRUE)


# VISUALIZACION DE DATOS --------------------------------------------------


library(tidyverse)
#> ── Attaching core tidyverse packages ───────────────────── tidyverse 2.0.0 ──
#> ✔ dplyr     1.2.1     ✔ readr     2.2.0
#> ✔ forcats   1.0.1     ✔ stringr   1.6.0
#> ✔ ggplot2   4.0.3     ✔ tibble    3.3.1
#> ✔ lubridate 1.9.5     ✔ tidyr     1.3.2
#> ✔ purrr     1.2.2     
#> ── Conflicts ─────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
#> ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

library(palmerpenguins)
#> 
#> Attaching package: 'palmerpenguins'
#> The following objects are masked from 'package:datasets':
#> 
#>     penguins, penguins_raw
library(ggthemes)

PENGUINS
penguins

glimpse(penguins)
#> Rows: 344
#> Columns: 8
#> $ species           <fct> Adelie, Adelie, Adelie, Adelie, Adelie, Adelie, A…
#> $ island            <fct> Torgersen, Torgersen, Torgersen, Torgersen, Torge…
#> $ bill_length_mm    <dbl> 39.1, 39.5, 40.3, NA, 36.7, 39.3, 38.9, 39.2, 34.…
#> $ bill_depth_mm     <dbl> 18.7, 17.4, 18.0, NA, 19.3, 20.6, 17.8, 19.6, 18.…
#> $ flipper_length_mm <int> 181, 186, 195, NA, 193, 190, 181, 195, 193, 190, …
#> $ body_mass_g       <int> 3750, 3800, 3250, NA, 3450, 3650, 3625, 4675, 347…
#> $ sex               <fct> male, female, female, NA, female, male, female, m…
#> $ year              <int> 2007, 2007, 2007, 2007, 2007, 2007, 2007, 2007, 2…


# CREACION DE UN GGPLOT ---------------------------------------------------


ggplot(data = penguins)


ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
)

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point()
#> Warning: Removed 2 rows containing missing values or values outside the scale range
#> (`geom_point()`).



# AÑADIR ESTETICA Y CAPAS -------------------------------------------------

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) +
  geom_point()


ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) +
  geom_point() +
  geom_smooth(method = "lm")

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(mapping = aes(color = species)) +
  geom_smooth(method = "lm")

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(mapping = aes(color = species, shape = species)) +
  geom_smooth(method = "lm")


ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(aes(color = species, shape = species)) +
  geom_smooth(method = "lm") +
  labs(
    title = "Body mass and flipper length",
    subtitle = "Dimensions for Adelie, Chinstrap, and Gentoo Penguins",
    x = "Flipper length (mm)", y = "Body mass (g)",
    color = "Species", shape = "Species"
  ) +
  scale_color_colorblind()



# EJERCICIOS --------------------------------------------------------------

# 1. ¿Cuántas filas hay? ¿Cuántas columnas?

penguins

# hay 344 filas y 8 columnas

# 2. ¿Qué describe la variable en el marco de datos? 

bill_depth_mmpenguins
bill_depth_mmpenguins?penguins

# la variable describe la profundidad del pico del pinguino en milimetros.

# 3. Haz un gráfico de dispersión de vs. Es decir, hacer un diagrama de dispersión 
# con en el eje y y en el eje x. Describe la relación entre estas dos variables

ggplot(data = penguins, mapping = aes(x = bill_length_mm, y = bill_depth_mm)) + geom_point()


# si se mira todo junto la relacion parece debil o ligeramente negativa
# pero se observa que los grupos se agrupan en 3 grupos (que corresponden a las diferentes especies de pinguinos)

# 4. ¿Qué ocurre si haces un gráfico de dispersión de vs. ? ¿Cuál podría ser una mejor opción de geom?

# grafico de dispersion

ggplot(data = penguins, mapping = aes(x = species, y = bill_depth_mm)) + geom_point()
# en este grafico ocurre que los puntos se alinean en columnas verticales sobre cada especie
# lo que dificulta ver la distribucion de los datos superpuestos


# mejor opcion: grafico de boxplot =============================================

ggplot(data = penguins, mapping = aes(x = species, y = bill_depth_mm)) + geom_boxplot()
# El grafico de caja permiteresumir y comparar visualmente la distribucion del pico entre las especies de manera mucho mas clara


# 5. ¿Por qué lo siguiente da un error y cómo lo solucionarías?

ggplot(data = penguins) + 
  geom_point()

# da error porque la funcion geom_point() requiere que se definan las variables para los ejes x e y 
# dentro del argumento 

#solucion: ============================================================
#se debe aggregar el argumento mapping con sus variables

ggplot(data =  penguins) + 
  geom_point(mapping = aes(x = bill_length_mm, y = bill_depth_mm))


# 6. ¿Qué hace el argumento en ? ¿Cuál es el valor predeterminado del argumento? 

ggplot(penguins, aes(x = bill_length_mm, y = bill_depth_mm)) + 
  geom_point(na.rm = TRUE)

ggplot(penguins, aes(x = bill_length_mm, y = bill_depth_mm)) + 
  geom_point()

# 7.  PIE DE FOTO


ggplot(penguins, aes(x = bill_length_mm, y = bill_depth_mm)) +
  geom_point(na.rm = TRUE) +
  labs(
    title = "Relación entre largo y profundidad del pico",
    subtitle = "Datos de tres especies de pingüinos",
    x = "Largo del pico (mm)",
    y = "Profundidad del pico (mm)",
    caption = "Fuente: palmerpenguins"
  )


# 8. recrear imagen


# Mapeo global: se aplica a todos los geoms
ggplot(penguins, aes(x = bill_length_mm, y = bill_depth_mm)) +
  geom_point(na.rm = TRUE) +
  geom_smooth(method = "lm", na.rm = TRUE)

# Mapeo local: solo afecta al geom_point
ggplot(penguins, aes(x = bill_length_mm)) +
  geom_point(aes(y = bill_depth_mm), na.rm = TRUE) +
  geom_smooth(method = "lm", na.rm = TRUE)

library(ggplot2)
library(palmerpenguins)

# Ejercicio 8: gráfico con color por especie
ggplot(penguins, aes(x = bill_length_mm, y = bill_depth_mm, color = species)) +
  geom_point(na.rm = TRUE) +
  geom_smooth(method = "lm", se = FALSE, na.rm = TRUE) +
  labs(
    title = "Relación entre largo y profundidad del pico",
    subtitle = "Coloreado por especie de pingüino",
    x = "Largo del pico (mm)",
    y = "Profundidad del pico (mm)",
    caption = "Fuente: palmerpenguins"
  ) +
  theme_minimal()

ggplot(penguins, aes(x = bill_length_mm, y = bill_depth_mm)) +
  geom_point(na.rm = TRUE)

ggplot(penguins, aes(x = bill_length_mm, y = bill_depth_mm)) +
  geom_point(na.rm = TRUE) +
  labs(
    title = "Relación entre largo y profundidad del pico",
    subtitle = "Datos de tres especies de pingüinos",
    x = "Largo del pico (mm)",
    y = "Profundidad del pico (mm)",
    caption = "Fuente: palmerpenguins"
  )

ggplot(penguins, aes(x = bill_length_mm, y = bill_depth_mm, color = species)) +
  geom_point(na.rm = TRUE) +
  geom_smooth(method = "lm", se = FALSE, na.rm = TRUE)

ggplot(data = penguins, mapping = aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(mapping = aes(color = species, shape = species)) +
  geom_smooth(method = "lm")

# tuve que empezar de nuevo porque no me salia el grafico
ggplot(data =  penguins, mapping = aes(x = flipper_length_mm, y = body_mass_g, color = bill_depth_mm)) + 
  geom_point()

ggplot(data =  penguins, mapping = aes(x = flipper_length_mm, y = body_mass_g, color = bill_depth_mm)) + 
  geom_point(na.rm = TRUE)
  geom_smooth(method = "lm")

# 9. 
  
  ggplot(
    data = penguins,
    mapping = aes(x = flipper_length_mm, y = body_mass_g, color = island)
  ) +
    geom_point() +
    geom_smooth(se = FALSE)
  
  # 10. ¿Estos dos gráficos se verán diferentes? ¿Por qué o por qué no?
  
  ggplot(
    data = penguins,
    mapping = aes(x = flipper_length_mm, y = body_mass_g)
  ) +
    geom_point() +
    geom_smooth()
  
  ggplot() +
    geom_point(
      data = penguins,
      mapping = aes(x = flipper_length_mm, y = body_mass_g)
    ) +
    geom_smooth(
      data = penguins,
      mapping = aes(x = flipper_length_mm, y = body_mass_g)
    )
  
  #si, recrean el mismo grafico
  

# LLAMADAS GGPLOT2 --------------------------------------------------------

  
  ggplot(
    data = penguins,
    mapping = aes(x = flipper_length_mm, y = body_mass_g)
  ) +
    geom_point()
  
  
  ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) + 
    geom_point()
  
  
  penguins |> 
    ggplot(aes(x = flipper_length_mm, y = body_mass_g)) + 
    geom_point()
  
  

# VISUALIZACION DE DISTRIBUCIONES -----------------------------------------

  
  #una variable categorica
  ggplot(penguins, aes(x = species)) +
    geom_bar()
  
  ggplot(penguins, aes(x = fct_infreq(species))) +
    geom_bar()
  
  #una variable numerica
  ggplot(penguins, aes(x = body_mass_g)) +
    geom_histogram(binwidth = 200)
  
  ggplot(penguins, aes(x = body_mass_g)) +
    geom_histogram(binwidth = 20)
  ggplot(penguins, aes(x = body_mass_g)) +
    geom_histogram(binwidth = 2000)
  
  ggplot(penguins, aes(x = body_mass_g)) +
    geom_density()
  #> Warning: Removed 2 rows containing non-finite outside the scale range
  #> (`stat_density()`).
  
  
  #EJERCICIOS======================================================
  
  # 1. Haz un gráfico de barras de , donde asignas a la estética. ¿En qué se diferencia esta trama?
  
  ggplot(data = penguins, mapping = aes(x = species)) +
    geom_bar()

  #el grafico genera 3 barras, lo que se nota de particular es que no
  #necesitamos especificar un eje y ya que geom_bar()
  #calcula automaticamente el conteo.
  
  # 2. ¿En qué se diferencian las dos siguientes tramas?
  # ¿Qué estética, o , es más útil para cambiar el color de las barras?
  
  ggplot(penguins, aes(x = species)) +
    geom_bar(color = "red")
  
  ggplot(penguins, aes(x = species)) +
    geom_bar(fill = "red")
  
  # el rpimer codigo te deja las barras grises con una linea roja alrededor
  # el segundo codigo pinta las barras completamente de rojo
  
  # 3.¿Qué hace el argumento en?
  
  geom_histogram()
  
  
  # 4. histograma
  
  library(tidyverse)
  

  ggplot(diamonds, aes(x = carat)) +
    geom_histogram(binwidth = 0.1)
  
  # Probar con otros anchos de bin
  ggplot(diamonds, aes(x = carat)) +
    geom_histogram(binwidth = 0.05)
  
  ggplot(diamonds, aes(x = carat)) +
    geom_histogram(binwidth = 0.5)
  
  ggplot(diamonds, aes(x = carat)) +
    geom_histogram(binwidth = 1)

  
    # el ancho de bin afecta la interpretación del histograma: valores pequeños muestran detalle 
    # pero pueden ser ruidosos, mientras que valores grandes simplifican y resaltan tendencias generales.
  
  

# VISUALIZACION DE RELACIONES ---------------------------------------------


  # Una variable numerica y una categorica
  
  ggplot(penguins, aes(x = species, y = body_mass_g)) +
    geom_boxplot()
  
  ggplot(penguins, aes(x = body_mass_g, color = species)) +
    geom_density(linewidth = 0.75)
  
  ggplot(penguins, aes(x = body_mass_g, color = species, fill = species)) +
    geom_density(alpha = 0.5)
  
  
  # dos variables categoricas
  
  ggplot(penguins, aes(x = island, fill = species)) +
    geom_bar()
  
  ggplot(penguins, aes(x = island, fill = species)) +
    geom_bar(position = "fill")
  
  ggplot(penguins, aes(x = island, fill = species)) +
    geom_bar(position = "fill") +
    labs(y = "proportion")
  
  ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
    geom_point()
  
  
  # tres o mas variables
  
  ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
    geom_point(aes(color = species, shape = island))
  
  
  ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
    geom_point(aes(color = species, shape = species)) +
    facet_wrap(~island)
  
  # ejercicios 
  
  
  # 1.  ¿Qué variables en son categóricas? ¿Qué variables son numéricas?
  # (Pista: Escribe para leer la documentación del conjunto de datos.) 
  # ¿Cómo puedes ver esta información cuando corres?
  
  library(ggplot2)
  
  # Ver las primeras filas
  head(mpg)
  
  # Ver estructura completa
  glimpse(mpg)
  
  # En el dataset mpg, las variables categóricas son manufacturer, model, trans, drv, fl y class. 
  # Las variables numéricas son displ, year, cyl, cty y hwy. Esto se puede comprobar con
  # la función glimpse(mpg), que muestra el tipo de cada columna.
  
  
  # 2
  
  library(ggplot2)
  
  # Scatterplot de displ vs hwy
  ggplot(mpg, aes(x = displ, y = hwy)) +
    geom_point()
  
  # El gráfico de dispersión de displ vs hwy muestra una relación inversa:
  # los autos con mayor cilindrada tienen menor rendimiento en carretera. 
  # Esto sugiere que motores más grandes son menos eficientes en consumo de combustible.
  
  # 3. 
  
  library(ggplot2)
  
  # Usando color para diferenciar por clase de auto
  ggplot(mpg, aes(x = displ, y = hwy, color = class)) +
    geom_point()
  
  # Otra opción: usar forma de los puntos según tipo de tracción
  ggplot(mpg, aes(x = displ, y = hwy, shape = drv)) +
    geom_point()
  
  
  # Al agregar la variable class como color en el gráfico de dispersión,
  # se observa que los autos compactos y subcompactos tienden a tener menor cilindrada y 
  # mayor rendimiento en carretera, mientras que los SUV y camionetas tienen mayor cilindrada y 
  # menor rendimiento. Esto enriquece la interpretación del gráfico mostrando diferencias entre categorías de vehículos.
  
  
  # 4. ¿Qué ocurre si asignas la misma variable a varias estéticas?
  
  
  library(ggplot2)
  
  # Facet por clase de auto
  ggplot(mpg, aes(x = displ, y = hwy)) +
    geom_point() +
    facet_wrap(~ class)
  
  # Otra opción: facet por tipo de tracción
  ggplot(mpg, aes(x = displ, y = hwy)) +
    geom_point() +
    facet_wrap(~ drv)
  
  # Al aplicar facet_wrap(~ class) el gráfico se divide en paneles por categoría de auto.
  # Esto facilita comparar cómo varía la relación entre cilindrada y rendimiento en carretera 
  # dentro de cada clase. Se observa que los autos compactos y subcompactos tienen menor cilindrada y
  # mayor eficiencia, mientras que los SUV y camionetas muestran mayor cilindrada y menor rendimiento.
  
  
  # 5.
  
  ggplot(
    data = penguins,
    mapping = aes(
      x = bill_length_mm, y = bill_depth_mm, 
      color = species, shape = species
    )
  ) +
    geom_point() +
    labs(color = "Species")
  
  
  ggplot(penguins, aes(x = island, fill = species)) +
    geom_bar(position = "fill")
  ggplot(penguins, aes(x = species, fill = island)) +
    geom_bar(position = "fill")
  
  
  ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
    geom_point()
  ggsave(filename = "penguin-plot.png")
  