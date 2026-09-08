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