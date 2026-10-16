# ANALISID DE RED - Libro 4 game of thrones

# INTEGRANTES: Milagros Fernandez (915473) y cristian contrera (918842)

library(tidygraph)
library(tidyverse)
library(ggraph)
library(igraph)
library(influenceR)
library(ggrepel)


# Datos --------------------------------------------------------------------

setwd(choose.dir())

carpeta <- "." 

nodos   <- read_csv(file.path(carpeta, "asoiaf-book4-nodes.csv"),
                    show_col_types = FALSE)
aristas <- read_csv(file.path(carpeta, "asoiaf-book4-edges.csv"),
                    show_col_types = FALSE)

# Chequeo:

cat("Personajes (nodos):", nrow(nodos), "\n")
cat("Conexiones (aristas):", nrow(aristas), "\n")

# IMPORTANTE: renombro `weight` a `peso`. hay una columna llamada "weight"
# como si fuera una DISTANCIA (más peso = más lejos), y en esta red es al
# revés: más peso = más interacción.

aristas <- aristas %>%
  select(from = Source, to = Target, peso = weight)


# Grafo --------------------------------------------------------------------

grafo_base <- tbl_graph(
  nodes    = nodos,
  edges    = aristas,
  directed = FALSE,
  node_key = "Id"     
)

# ¿La red es una sola pieza o hay personajes desconectados del resto?
n_componentes <- grafo_base %>%
  activate(nodes) %>%
  mutate(comp = group_components()) %>%
  as_tibble() %>%
  summarise(n = n_distinct(comp)) %>%
  pull(n)

cat("Componentes conexas:", n_componentes, "\n")

# todos los personajes están conectados con todos mediante algún camino directo o indirecto


# Métricas por personaje ---------------------------------------------------

set.seed(123) 

grafo <- grafo_base %>%
  activate(nodes) %>%
  mutate(
    # degree: con cuántos personajes DISTINTOS aparece conectado
    degree = centrality_degree(),

    # fuerza: suma de pesos = cuánta interacción total tiene (complementa al degree)
    fuerza = centrality_degree(weights = peso),

    # grupos: comunidades que interactúan mucho entre sí y poco con el resto
    grupo = group_infomap(weights = peso),

    # centro: el/los personaje(s) desde los que se llega más cerca a todos
    centro = node_is_center(),

    # distancia (en saltos) hasta el centro
    dist_centro = node_distance_to(node_is_center(), mode = "all"),

    # keyplayers: los 10 personajes que, si se sacan de la red, más la fragmentan
    keyplayer = node_is_keyplayer(k = 10)
  )

resultados <- grafo %>%
  activate(nodes) %>%
  as_tibble()
resultados

# Respuestas a las preguntas -----------------------------------------------

# --- Pregunta 1: los 5 personajes con mayor degree --------------------------

top5_degree <- resultados %>%
  arrange(desc(degree), desc(fuerza)) %>%
  select(Label, degree, fuerza) %>%
  slice_head(n = 5)

cat("\n--- P1: Top 5 por degree ---\n")
print(top5_degree)

# Para contexto: los mismos 5 pero ordenados por fuerza
cat("\n--- Extra: Top 5 por fuerza (peso total) ---\n")
resultados %>%
  arrange(desc(fuerza)) %>%
  select(Label, fuerza, degree) %>%
  slice_head(n = 5) %>%
  print()


# --- Pregunta 2: ¿cuántos grupos detecta y qué significan? -------------------

n_grupos <- n_distinct(resultados$grupo)
cat("\n--- P2: Cantidad de grupos detectados:", n_grupos, "---\n")

resumen_grupos <- resultados %>%
  group_by(grupo) %>%
  summarise(
    integrantes = n(),
    # los 5 personajes con más degree de cada grupo, para poder interpretarlo
    principales = paste(Label[order(-degree)][seq_len(min(5, n()))],
                        collapse = ", "),
    .groups = "drop"
  ) %>%
  arrange(desc(integrantes))

print(resumen_grupos, n = Inf, width = Inf)

# se detectaron 28 comunidades.


# --- Pregunta 3 (versión dentro del libro 4) ---------------------------------
# ¿hay keyplayers que NO están entre los 10 con más degree? Son personajes importantes para que la
# red no se rompa aunque no sean los más conectados.

top10_degree <- resultados %>%
  arrange(desc(degree), desc(fuerza)) %>%
  slice_head(n = 10) %>%
  pull(Id)

cat("\n--- keyplayers (k = 10) ---\n")
resultados %>%
  filter(keyplayer) %>%
  arrange(desc(degree)) %>%
  mutate(entre_top10_degree = Id %in% top10_degree) %>%
  select(Label, degree, fuerza, entre_top10_degree) %>%
  print(n = Inf)

cat("\nTop 10 por degree que NO son keyplayers:\n")
resultados %>%
  filter(Id %in% top10_degree, !keyplayer) %>%
  select(Label, degree, fuerza) %>%
  print(n = Inf)


# --- Pregunta 4: key player principal del libro -------------------------------

cat("\n--- Candidatos a key player principal ---\n")

cat("\nCentro de la red:\n")
resultados %>% filter(centro) %>% select(Label, degree, fuerza) %>% print()
# Por Posición Estructural Geométrica: stannis Baratheon


cat("\nKeyplayer con más degree:\n")
resultados %>%
  filter(keyplayer) %>%
  arrange(desc(degree), desc(fuerza)) %>%
  select(Label, degree, fuerza) %>%
  slice_head(n = 1) %>%
  print()
# por alcance y conexiones directas: Jaime Lannister


cat("\nKeyplayer con más fuerza:\n")
resultados %>%
  filter(keyplayer) %>%
  arrange(desc(fuerza)) %>%
  select(Label, degree, fuerza) %>%
  slice_head(n = 1) %>%
  print()
# por intensidad y concentracion de dialogo: Cersei Lannister



# 5. Gráficos -----------------------------------------------------------------


#install.packages("gt")
library(tidyverse)
library(gt)

# Crear tabla comparativa formateada
tabla_kpi <- resultados %>%
  arrange(desc(degree), desc(fuerza)) %>%
  slice_head(n = 5) %>%
  select(Label, degree, fuerza) %>%
  mutate(
    Ratio = round(fuerza / degree, 1),
    Rol = c(
      "Líder en Alcance (Militar / Itinerante)",
      "Líder en Intensidad (Político / Corte)",
      "Búsqueda territorial",
      "Secuelas / Memorias",
      "Consolidación de corte"
    )
  ) %>%
  gt() %>%
  tab_header(
    title = md("**Panel: Top 5 Personajes en el Libro 4**"),
    subtitle = "Comparativa de Alcance (Degree) vs. Masa de Diálogo (Fuerza)"
  ) %>%
  cols_label(
    Label = "Personaje",
    degree = "Degree",
    fuerza = "Fuerza",
    Ratio = "Intensidad Relativa",
    Rol = "Rol Narrativo Principal"
  ) %>%
  # Destacar a Jaime y Cersei con colores
  tab_style(
    style = list(
      cell_fill(color = "#e8f0fe"),
      cell_text(weight = "bold")
    ),
    locations = cells_body(rows = Label == "Jaime Lannister")
  ) %>%
  tab_style(
    style = list(
      cell_fill(color = "#fce8e6"),
      cell_text(weight = "bold")
    ),
    locations = cells_body(rows = Label == "Cersei Lannister")
  ) %>%
  tab_source_note(
    source_note = "ECON 520 - Analisis de Redes - libro 4 | FCE - UBA"
  )

print(tabla_kpi)
