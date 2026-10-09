
# Uriel Kogan (917023), Milagros Fernandez (915473), Tiffany Wolodko (911660)
# ECON 520 - TRABAJO EN CLASE: grupo 4 datasets: "immuno"

library(igraph)
library(igraphdata)

data(immuno) 
g <- immuno


# A. CARACTERISTICAS DE LA RED --------------------------------------------

g

# Resumen general del grafo

summary(g)

# ¿Cuántos nodos y aristas tiene?

V(g)  # tiene 1316 nodos
E(g)    # tiene 6300 links
vcount(g)   
ecount(g) 

# ¿Qué atributos tienen los nodos y las aristas?

vertex_attr_names(g)   #no presenta atributos
edge_attr_names(g)   # no presenta atributos

# ¿Es dirigida o no dirigida? ¿Es ponderada o no ponderada?

is_directed(g)    # no es una red dirigida 
is_weighted(g)   # no es una red ponderada 

# ¿La red está conectada? Si no, ¿cuántos componentes tiene y qué tamaño tiene el más grande?

is_connected(g)   # si esta conectada

n_comp    # tiene 1 componente
comp <- components(g)
n_comp <- comp$no
tam_gigante <- max(comp$csize)
max(comp$csize)    # el componente mas grande tiene 1365 (100% de los nodos)



# B. COMO SE CONECTA ------------------------------------------------------

# Grado promedio y mediana. Son parecidos o muy distintos? Qué dice eso sobre la red?

grados <- degree(g)

mean(grados)  #el grado promedio es 9.8
median(grados)  #la mediana del grado es 10
max(grados)     # el grado maximo es 17

#Como la media 9.8 y la mediana 10 están prácticamente pegadas, 
#la masa principal de los datos es sustancialmente simétrica alrededor de 10.
#el valor max es 17, considerablemente alejado de la media y la mediana.
#Esto indica la presencia de valores atípicos a la derecha o una cola larga hacia valores altos.

# Histograma de grados

hist(grados, 
     main = "Histograma de Grados", 
     xlab = "Grado (k)", 
     ylab = "Frecuencia", 
     col = "skyblue", 
     border = "white")

# cuales son los 5 nodos mas conectados

top5 <- sort(deg, decreasing = TRUE)[1:5]
print(top5)

?immuno

# Densidad

edge_density(g) #como esta cercano a 0 es esparsa.


# C. ESTRUCTURA DE LA RED -------------------------------------------------


# Coeficiente de clustering global (transitividad)

transitivity(g, type = "global") # lo comparamos con la densidad
edge_density(g) 

# como el clustering global es mayor a la densidad, el nivel de clustering es alto.


# Distancia promedio entre nodos

mean_distance(g) 

# Detección de comunidades (convirtiendo a no dirigida si hace falta)

set.seed(1)
com <- cluster_louvain(g)

length(com)

# hay 13 comunidades
