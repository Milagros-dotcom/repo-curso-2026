setwd(choose.dir())
sink("tarea02.txt", split = TRUE)


# TRANSFORMACION DE DATOS -------------------------------------------------

library(nycflights13)
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

flights
# Contiene los 336.776 vuelos que partieron de la ciudad de nueva york

glimpse(flights)


# Conceptos basicos de DPLYR (FUNCIONES) -------------------------------------------------------------------------

#Los verbos de dplyr se organizan en cuatro grupos según lo que operan: filas, columnas, grupos o tablas.
flights |>
  filter(dest == "IAH") |> 
  group_by(year, month, day) |> 
  summarize(
    arr_delay = mean(arr_delay, na.rm = TRUE)
  )



# FILAS -------------------------------------------------------------------
   # filter(), arrange(), distinct(), arrange()

 
 #filter() te permite mantener filas basadas en los valores de las columnas1.
 #El primer argumento es el marco de datos. El segundo y los argumentos posteriores 
 #son las condiciones que deben ser válidas para mantener la disputa.

#vuelos con mas de 120 min de retaso de salida
flights |> 
  filter(dep_delay > 120)

#vuelos del 1 de enero
flights |> 
  filter(month == 1 & day == 1)

#vuelos de enero o febrero
flights |> 
  filter(month == 1 | month == 2)

#forma corta con %in%
flights |> 
  filter(month %in% c(1, 2))

#guardar el resultado en una variable
jan1 <- flights |> 
  filter(month == 1 & day == 1)

   # errores comunes
 
flights |> 
  filter(month = 1)

flights |> 
  filter(month == 1 | 2)

 
 # arrange() ....................................................................................
 #cambia el orden de las filas en función del valor de las columnas. 
 # Requiere un marco de datos y un conjunto de nombres de columnas para ordenar. 
 # Si proporcionas más de un nombre de columna, cada columna adicional se usará para desempatar los valores de las columnas anteriores.


# ordenar por fecha y hora de salida
flights |> 
  arrange(year, month, day, dep_time)

# ordenar de mayor a menor retraso de salida
flights |> 
  arrange(desc(dep_delay))


 # distinct() .....................................................................................
 # encuentra todas las filas únicas en un conjunto de datos, así que técnicamente, opera principalmente sobre las filas.


# eliminar filas duplicadas
flights |> 
  distinct()

# pares unicos de origen y destino
flights |> 
  distinct(origin, dest)

# mantener todas las columnas conservando la primera aparicion
flights |> 
  distinct(origin, dest, .keep_all = TRUE)

# contar frecuencias de pares origen destino
flights |>
  count(origin, dest, sort = TRUE)


# 3.2.5 ejercicios --------------------------------------------------------

# 1. En una sola cadena para cada condición, encuentra todos los vuelos que cumplan la condición:

 # llegada de dos o mas horas de retraso
flights |> 
  filter(arr_delay >= 120)

 # volaron a houston
flights |> 
  filter(dest %in% c("IAH", "HOU"))

 # fueron operados por united, american o delta
flights |> 
  filter(carrier %in% c("UA", "AA", "DL"))

 # Partió en verano (julio, agosto y septiembre)
flights |> 
  filter(month %in% c(7, 8, 9))

# Llegó con más de dos horas de retraso pero no salió tarde
flights |> 
  filter(arr_delay > 120 & dep_delay <= 0)

# Me retrasaron al menos una hora, pero recuperaron más de 30 minutos en vuelo
flights |> 
  filter(dep_delay >= 60 & (dep_delay - arr_delay) > 30)

# 2. Busca los vuelos con los retrasos de salida más largos. Busca los vuelos que salían más temprano por la mañana.

 # vuelos con mayores retrasos de salida
flights |> 
  arrange(desc(dep_delay))

 # vuelos que salian mas temprano en la mañana
flights |> 
  arrange(dep_time)

# 3. Busca los vuelos mas rapidos
flights |> 
  arrange(desc(distance / air_time))


# 4. ¿Había vuelo todos los días de 2013?
flights |> 
  distinct(year, month, day) |> 
  nrow()
# si, el resultado dice los 365 dias del año


# 5. ¿Qué vuelos recorrieron la distancia más larga? ¿Cuál recorrió menos distancia?

 # mayor distancia recorrida
flights |> 
  arrange(desc(distance))

flights |> 
  slice_max(distance, n = 1) |> 
  select(origin, dest, distance, carrier)
 # el trayecto mas largo es de jfk a hnl con 4983 millas

 # menor distancia recorrida
flights |> 
  arrange(distance)

flights |> 
  slice_min(distance, n = 1) |> 
  select(origin, dest, distance, carrier)
 # el trayecto mas corto fue de EWR a LGA con 17 millas


# 6. ¿Importa el orden que usaste y si usas ambos? ¿Por qué o por qué no?

 # Es mejor ejecutar primero filter() y después arrange(). 
 # Al filtrar primero, reduces la cantidad de filas que R tiene que ordenar en memoria, 
 # haciendo la ejecución mucho más rápida y eficiente.



# COLUMNAS ----------------------------------------------------------------

 #crean nuevas columnas derivadas de las existentes, cambian qué columnas están presentes, 
 #cambian los nombres de las columnas y cambian la posición de las columnas.mutate()select()rename()relocate()

 # mutate

# Crear nuevas variables (ganancia de tiempo y velocidad en mph)
flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time * 60
  )

# Agregar las variables al inicio (.before = 1)
flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time * 60,
    .before = 1
  )

# Conservar únicamente las columnas involucradas
flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    hours = air_time / 60,
    gain_per_hour = gain / hours,
    .keep = "used"
  )

# --- select() ---

# Seleccionar columnas específicas por nombre
flights |> 
  select(year, month, day)

# Seleccionar un rango de columnas
flights |> 
  select(year:day)

# Excluir un rango de columnas
flights |> 
  select(!year:day)

# Seleccionar solo columnas de texto
flights |> 
  select(where(is.character))

# Renombrar mientras se selecciona
flights |> 
  select(tail_num = tailnum)

# --- rename() ---

# Renombrar conservando el resto de columnas
flights |> 
  rename(tail_num = tailnum)

# --- relocate() ---

# Mover variables al principio
flights |> 
  relocate(time_hour, air_time)

# Mover con .after o .before
flights |> 
  relocate(year:dep_time, .after = time_hour)

flights |> 
  relocate(starts_with("arr"), .before = dep_time)


# EJERCICIOS 3.3.5 --------------------------------------------------------

 # 1. Compara , , y . ¿Cómo esperarías que estuvieran relacionados esos tres números?
 # dep_timesched_dep_timedep_delay

 # 2. Haz una lluvia de ideas en todas las formas posibles de seleccionar , , , y de .

# Opción A: Nombrar cada columna explícitamente
flights |> select(dep_time, dep_delay, arr_time, arr_delay)

# Opción B: Combinando patrones de nombres (empiezan o terminan con)
flights |> select(starts_with("dep_"), starts_with("arr_"))

# Opción C: Con expresiones regulares
flights |> select(matches("^(dep|arr)_(time|delay)$"))

# Opción D: Usando un vector de caracteres
vars <- c("dep_time", "dep_delay", "arr_time", "arr_delay")
flights |> select(all_of(vars))

 # 3. ¿Qué ocurre si especificas el nombre de la misma variable varias veces en una llamada?

flights |> select(dep_time, dep_time, dep_time)
  
 
 # 4. ¿Qué hace la función? ¿Por qué podría ser útil junto con este vector?any_of()

variables <- c("year", "month", "day", "dep_delay", "arr_delay")

variables <- c("year", "month", "day", "dep_delay", "arr_delay")
flights |> select(any_of(variables))

# any_of() selecciona las variables contenidas en el vector que realmente existen en el dataset
 
 # 5. ¿Te sorprende el resultado de ejecutar el siguiente código? ¿Cómo gestionan los ayudantes selectos las mayúsculas y minúsculas por defecto? ¿Cómo puedes cambiar ese valor por defecto?

flights |> select(contains("TIME"))


 # 7. ¿Por qué no funciona lo siguiente y qué significa el error?

flights |> 
  select(tailnum) |> 
  arrange(arr_delay)

# el comando no funciona porque hay que ordenarlo

flights |> 
  arrange(arr_delay) |> 
  select(tailnum)


#  LA TUBERIA -------------------------------------------------------------


flights |> 
  filter(dest == "IAH") |> 
  mutate(speed = distance / air_time * 60) |> 
  select(year:day, dep_time, carrier, flight, speed) |> 
  arrange(desc(speed))

arrange(
  select(
    mutate(
      filter(
        flights, 
        dest == "IAH"
      ),
      speed = distance / air_time * 60
    ),
    year:day, dep_time, carrier, flight, speed
  ),
  desc(speed)
)

flights1 <- filter(flights, dest == "IAH")
flights2 <- mutate(flights1, speed = distance / air_time * 60)
flights3 <- select(flights2, year:day, dep_time, carrier, flight, speed)
arrange(flights3, desc(speed))


#  GRUPOS -----------------------------------------------------------------


flights |> 
  group_by(month)

flights |> 
  group_by(month) |> 
  summarize(
    avg_delay = mean(dep_delay)
  )

flights |> 
  group_by(month) |> 
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE)
  )

flights |> 
  group_by(month) |> 
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE),
    n = n()
  )

# --- Funciones slice_ ---
# Vuelos con el mayor retraso de llegada según destino
flights |> 
  group_by(dest) |> 
  slice_max(arr_delay, n = 1) |>
  relocate(dest)

# --- Agrupar por múltiples variables  ---
daily <- flights |>  
  group_by(year, month, day)

daily_flights <- daily |> 
  summarize(n = n())

daily_flights <- daily |> 
  summarize(
    n = n(), 
    .groups = "drop_last"
  )

# Desagrupar

daily |> 
  ungroup()

daily |> 
  ungroup() |>
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE), 
    flights = n()
  )

# --- .by (Agrupamiento por operación) ---
flights |> 
  summarize(
    delay = mean(dep_delay, na.rm = TRUE), 
    n = n(),
    .by = month
  )

flights |> 
  summarize(
    delay = mean(dep_delay, na.rm = TRUE), 
    n = n(),
    .by = c(origin, dest)
  )


# EJERCICIOS 3.5.7 --------------------------------------------------------------

 # 1. ¿Qué operadora tiene los peores retrasos medios? Desafío:
 # ¿se pueden distinguir los efectos de aeropuertos deficientes frente a los de transportistas malos?
 # ¿Por qué o por qué no?

# Peores retrasos promedio por aerolínea
flights |> 
  group_by(carrier) |> 
  summarize(avg_dep_delay = mean(dep_delay, na.rm = TRUE)) |> 
  arrange(desc(avg_dep_delay))

# Desenredar aeropuerto vs aerolínea (agrupando por carrier y dest)
flights |> 
  group_by(carrier, dest) |> 
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )

# Explicación del desafío: Es difícil separarlos por completo porque algunas aerolíneas 
# controlan ciertos aeropuertos (hubs) y no vuelan a todos los destinos por igual, 
# confundiendo el efecto del aeropuerto con el de la aerolínea.


# 2. Busca los vuelos que más retrasos se retrasan al salir a cada destino.

flights |> 
  group_by(dest) |> 
  slice_max(dep_delay, n = 1) |> 
  relocate(dest, dep_delay)

# 3. ¿Cómo varían los retrasos a lo largo del día? Ilustra tu respuesta con una trama.

flights |> 
  group_by(hour) |> 
  summarize(avg_dep_delay = mean(dep_delay, na.rm = TRUE)) |> 
  ggplot(aes(x = hour, y = avg_dep_delay)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Retraso promedio de salida según la hora del día",
    x = "Hora del día",
    y = "Retraso promedio (minutos)"
  )

# 4. ¿Qué pasa si le das un negativo a tus amigos?nslice_min()

# Al usar un 'n' negativo, la función invierte el comportamiento y devuelve 
# todas la filas excepto las 'n' con los valores más extremos.
# Ejemplo: elimina la fila con la menor distancia por grupo
flights |> 
  group_by(dest) |> 
  slice_min(distance, n = -1)

# 5. Explica qué significa en términos de los verbos dplyr que acabas de aprender. ¿Qué significa el argumento?count()sortcount()

# count() equivale a hacer group_by() seguido de summarize(n = n()).
# El argumento 'sort = TRUE' ordena los resultados de mayor a menor cantidad.
flights |> 
  count(dest, sort = TRUE)

# EJERCICIO 6

df <- tibble(
  x = 1:5,
  y = c("a", "b", "a", "a", "b"),
  z = c("K", "K", "L", "L", "K")
)

# A. Anota cómo crees que será el resultado, luego comprueba si estabas en lo correcto y describe qué es lo que sí

df |> 
  group_by(y)
# Devuelve el mismo df pero añade metadatos indicando agrupamiento por 'y'.

# B. 

df |> 
  arrange(y)
# Reordena las filas alfabéticamente según 'y' (a, a, a, b, b). A diferencia de group_by, modifica el orden visible.

# C.

df |> 
  group_by(y) |> 
  summarize(mean_x = mean(x))
# Calcula el promedio de 'x' para cada grupo de 'y' (a=2.67, b=3.5).

# D.

df |> 
  group_by(y, z) |> 
  summarize(mean_x = mean(x))
# Agrupa por combinación de 'y' y 'z' y saca el promedio. El mensaje avisa que el resultado queda agrupado solo por 'y'.

# E.

df |>
  group_by(y, z) |>
  summarize(mean_x = mean(x), .groups = "drop")
# Igual al anterior, pero elimina todo agrupamiento del tibble resultante (.groups = "drop").

# F.

df |> 
  group_by(y, z) |> 
  summarize(mean_x = mean(x))

df |> 
  group_by(y, z) |> 
  mutate(mean_x = mean(x))
# summarize() reduce las filas a 1 por combinación de grupo. mutate() conserva todas las filas originales agregando la columna con el promedio de su grupo.


# 19.2.4 ejercicios: Keys -------------------------------------------------------

library(nycflights13)
library(tidyverse)

# ejercicio 1.

# Explicación: 
# La relación se establece mediante la clave 'origin' en 'weather' y 'faa' en 'airports'.
# 'origin' (weather) es una clave foránea (foreign key) que hace referencia a 'faa' (airports),
# la cual es la clave primaria (primary key).
# En el diagrama, debe aparecer una flecha o línea conectando 'weather$origin' con 'airports$faa'.

# ejercicio 2.

# Explicación:
# Actualmente 'weather' solo conecta con 'flights' a través de los aeropuertos de origen ('origin')[cite: 1].
# Si tuviera información de todos los aeropuertos del país, haría una conexión adicional con 
# la columna de destino 'dest' en 'flights'[cite: 1]. Esto permitiría analizar el clima al momento de la llegada.

# ejercicio 3.

weather |> 
  count(year, month, day, hour, origin) |> 
  filter(n > 1)
# Explicación:
# Ocurre el 3 de noviembre de 2013 a la 1:00 AM[cite: 1]. Ese día finaliza el horario de verano 
# (Daylight Saving Time) en EE. UU. y el reloj se retrasa una hora, por lo que la 1:00 AM transcurre dos veces.

# ejercicio 4.

special_days <- tibble(
  year = 2013,
  month = c(12, 12),
  day = c(24, 25),
  holiday = c("Nochebuena", "Navidad")
)

# Clave primaria: La combinación compuesta por (year, month, day)
# Conexión: Se une a 'flights' relacionando las tres columnas mediante un left_join:
flights |> 
  left_join(special_days, join_by(year, month, day))

# ejercicio 5.

install.packages("Lahman")

library(Lahman)

Batting


# People: 'playerID' es la clave primaria
People |> count(playerID) |> filter(n > 1)

# Batting: Usa clave compuesta (playerID, yearID, stint)
Batting |> count(playerID, yearID, stint) |> filter(n > 1)

# Salaries: Usa clave compuesta (playerID, yearID, teamID)
Salaries |> count(playerID, yearID, teamID) |> filter(n > 1)

# 1. 'People' es la tabla central. Su clave primaria es 'playerID'.
# 2. 'Batting' se conecta a 'People' mediante 'playerID', que actúa como clave foránea.
#    (La clave primaria propia de Batting es compuesta: playerID, yearID, stint).
# 3. 'Salaries' se conecta a 'People' mediante 'playerID' como clave foránea.
#    (La clave primaria propia de Salaries es compuesta: playerID, yearID, teamID).

# 1. 'People' contiene los datos demográficos de cada persona con clave primaria 'playerID'.
# 2. 'Managers' contiene los datos de dirección técnica de equipos y se conecta a 'People' 
#    usando 'playerID' como clave foránea.
# 3. 'AwardsManagers' contiene los premios ganados por los mánagers y se conecta a 'People'
#    usando 'playerID' como clave foránea.

# - Las tres tablas ('Batting', 'Pitching' y 'Fielding') comparten exactamente la misma
#   clave primaria compuesta: (playerID, yearID, stint).
# - Se caracterizan por tener una relación de 1 a 1 (o 1 a muchos si un jugador no
#   desempeña cierto rol) en el mismo nivel de agregación (jugador, año y etapa).
# - Cada una representa un aspecto distinto del juego de béisbol (ofensiva/bateo, 
#   lanzamiento/pitcheo y defensa/fildeo) para una misma observación.


# EJERCICIOS 19.3.4 -------------------------------------------------------

flights2 <- flights |> 
  select(year, time_hour, origin, dest, tailnum, carrier)

# ejercicio 1.

worst_hours <- flights |> 
  group_by(time_hour) |> 
  summarize(avg_delay = mean(dep_delay, na.rm = TRUE)) |> 
  slice_max(avg_delay, n = 48)

worst_hours |> 
  left_join(weather, join_by(time_hour))

# Patrones observados: La mayoría de las horas con peores retrasos se concentran 
# en tormentas o malas condiciones de viento/visibilidad (días de tormentas estivales o heladas).

# ejercicio 2.

top_dest <- flights2 |>
  count(dest, sort = TRUE) |>
  head(10)

# Usamos semi_join para filtrar 'flights' conservando solo los destinos de 'top_dest'
flights |> 
  semi_join(top_dest, join_by(dest))

# ejercicio 3.

# Usamos anti_join para encontrar qué vuelos no tienen datos meteorológicos
flights |> 
  anti_join(weather, join_by(origin, time_hour))

# Respuesta: No todos tienen datos hay algunos registros de vuelos sin coincidencias en 'weather'.

# ejercico 4. 

flights2 |> 
  anti_join(planes, join_by(tailnum)) |> 
  count(carrier, sort = TRUE)

# ejercicio 5.

planes_carriers <- flights |> 
  filter(!is.na(tailnum)) |> 
  distinct(tailnum, carrier)

planes_carriers |> 
  count(tailnum) |> 
  filter(n > 1)

# Varios aviones son operados por más de una aerolínea.

planes |> 
  left_join(
    planes_carriers |> 
      group_by(tailnum) |> 
      summarize(carriers = paste(carrier, collapse = ", ")),
    join_by(tailnum)
  )

# ejercicio 6.

airports_locations <- airports |> 
  select(faa, lat, lon)

flights |> 
  left_join(airports_locations, join_by(origin == faa)) |> 
  rename(lat_origin = lat, lon_origin = lon) |> 
  left_join(airports_locations, join_by(dest == faa)) |> 
  rename(lat_dest = lat, lon_dest = lon)

# ejercicio 7.

airports |>
  semi_join(flights, join_by(faa == dest)) |>
  ggplot(aes(x = lon, y = lat)) +
  borders("state") +
  geom_point() +
  coord_quickmap()

avg_dest_delays <- flights |> 
  group_by(dest) |> 
  summarize(avg_arr_delay = mean(arr_delay, na.rm = TRUE))

airports |> 
  inner_join(avg_dest_delays, join_by(faa == dest)) |> 
  ggplot(aes(x = lon, y = lat, color = avg_arr_delay, size = avg_arr_delay)) +
  borders("state") +
  geom_point(alpha = 0.7) +
  coord_quickmap() +
  scale_color_viridis_c() +
  labs(
    title = "Retraso promedio de llegada por aeropuerto de destino",
    color = "Retraso (min)",
    size = "Retraso (min)"
  )

# ejercicio 8.

june13_delays <- flights |> 
  filter(year == 2013, month == 6, day == 13) |> 
  group_by(dest) |> 
  summarize(avg_arr_delay = mean(arr_delay, na.rm = TRUE))

airports |> 
  inner_join(june13_delays, join_by(faa == dest)) |> 
  ggplot(aes(x = lon, y = lat, size = avg_arr_delay, color = avg_arr_delay)) +
  borders("state") +
  geom_point(alpha = 0.7) +
  coord_quickmap() +
  scale_color_viridis_c() +
  labs(
    title = "Retrasos de vuelo el 13 de Junio de 2013",
    color = "Retraso (min)",
    size = "Retraso (min)"
  )