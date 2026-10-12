#install.packages("edgar")

setwd(choose.dir())

library(edgar)
library(tidyverse)  
library(tidytext)
library(textdata)
library(rvest)
library(xml2)
library(scales)
library(httr)
library(jsonlite)
library(dplyr)
library(stringr)


# Busco empresas argentinas que cotizan en el NYSE (USA) ------------------

# Primero armo una tabla solo con el nombre y el ticker de cada empresa
empresas_argentinas <- tibble(
  empresa = c("YPF", "Grupo Financiero Galicia", "Banco Macro", "BBVA Argentina",
              "Pampa Energia", "TGS", "Central Puerto", "Loma Negra",
              "Telecom Argentina", "IRSA", "Cresud", "Despegar",
              "ADECOAGRO", "Mercado Libre"),
  ticker  = c("YPF", "GGAL", "BMA", "BBAR", "PAM", "TGS", "CEPU", "LOMA",
              "TEO", "IRS", "CRESY", "DESP", "AGRO", "MELI")
)

user_agent <- "Milagros milagrosft301004@gmail.com" 

# Le pido los cik a la sec
respuesta <- GET(
  "https://www.sec.gov/files/company_tickers.json",
  add_headers(`User-Agent` = user_agent)
)

# Convierto la respuesta en una tabla
tickers_sec <- fromJSON(content(respuesta, as = "text", encoding = "UTF-8")) %>%
  bind_rows() %>%
  select(ticker, cik = cik_str, nombre_sec = title)

# Le pego el CIK a mi tabla
empresas_argentinas <- empresas_argentinas %>%
  left_join(tickers_sec, by = "ticker")

#chequeo que cada empresa tenga cik
print(empresas_argentinas)

# Despegar ya no está en la lista de la SEC, así que le pongo el CIK a mano
empresas_argentinas <- empresas_argentinas %>%
  mutate(cik = if_else(ticker == "DESP", 1692427, as.numeric(cik)))

print(empresas_argentinas)

ciks <- empresas_argentinas$cik %>% na.omit() %>% as.numeric()


# BAJO LA BASE DE DATOS DE LAS EMPRESAS -----------------------------------

# Utilizo 20-f para todas las empresas, y 10-k para MELI.

descargar <- TRUE

if (descargar) {
  reportes <- getFilings(
    cik.no       = ciks,
    form.type    = c("20-F", "10-K"),
    filing.year  = 2020:2026,   
    quarter      = 1:4,
    downl.permit = "y",
    useragent    = user_agent
  )
  
  glimpse(reportes)
  
  reportes %>%
    distinct(cik, company.name) %>%
    print(n = 50)
}

getwd()

# ARMO UNA TABLA CON LOS ARCHIVOS DESCARGADOS

archivos <- list.files(
  "Edgar_filings",
  pattern    = "\\.txt$", 
  recursive  = TRUE,        
  full.names = TRUE         
)

length(archivos)

tabla_archivos <- tibble(ruta = archivos, nombre = basename(archivos)) %>%
  separate(nombre, into = c("cik", "formulario", "anio", "numero"),
           sep = "_", extra = "merge") %>%
  mutate(cik = as.numeric(cik)) %>%
  left_join(empresas_argentinas, by = "cik") %>%
  mutate(empresa = coalesce(empresa, as.character(cik)))

print(tabla_archivos %>% select(empresa, formulario, anio), n = 100)


# Limpio el archivo de edgar para pasarlo a texto limpio
 # Leo todas las lineas y las pego en un solo texto
 # Me quedo solo con los documentos 20-f o 10-k
 # paso todo en minuscula para poder comparar palabras
leer_reporte <- function(ruta) {
  
  lineas <- readLines(ruta, warn = FALSE)
  texto  <- paste(lineas, collapse = " ")
  
  texto <- iconv(texto, from = "UTF-8", to = "ASCII", sub = " ")
  

  documentos <- str_split(texto, "<DOCUMENT>")[[1]]
  principal  <- documentos[str_detect(documentos, "^\\s*<TYPE>(20-F|10-K)")]
  
  if (length(principal) == 0) principal <- texto
  principal <- paste(principal, collapse = " ")
  
  principal <- str_remove_all(principal, "<[^>]+>")
  principal <- str_replace_all(principal, "&nbsp;|&#160;|&amp;", " ")
  
  str_to_lower(principal)
}


# ANALISIS DE TEXTO -------------------------------------------------------


palabras_clave <- c("inflation", "devaluation", "exchange controls", "default",
                    "restructuring", "imf", "capital controls", "price controls",
                    "country risk", "embi")

# Listas vacías donde voy a ir guardando los resultados de cada reporte.
lista_clave  <- list()   # conteo de palabras clave
lista_tokens <- list()   # conteo de todas las palabras (para tf-idf y sentimiento)

# leo y limpio el reporte:

for (i in 1:nrow(tabla_archivos)) {
  
  cat("Procesando", i, "de", nrow(tabla_archivos), ":",
      tabla_archivos$empresa[i], tabla_archivos$anio[i], "\n")
  
  texto <- leer_reporte(tabla_archivos$ruta[i])
  
  conteos <- sapply(palabras_clave, function(p) {
    str_count(texto, paste0("\\b", p, "\\b"))
  })
  
  lista_clave[[i]] <- tibble(
    empresa = tabla_archivos$empresa[i],
    anio    = tabla_archivos$anio[i],
    palabra = palabras_clave,
    veces   = as.numeric(conteos)
  )
  
  lista_tokens[[i]] <- tibble(texto = texto) %>%
    unnest_tokens(word, texto) %>%                     
    filter(str_detect(word, "^[a-z]+$"),               
           nchar(word) >= 3) %>%                       
    anti_join(stop_words, by = "word") %>%             
    count(word) %>%                                    
    mutate(empresa = tabla_archivos$empresa[i],
           anio    = tabla_archivos$anio[i])
}

# Junto los resultados de todos los reportes en una sola tabla
conteo_clave <- bind_rows(lista_clave)
conteo_todas <- bind_rows(lista_tokens)


# RESULTADOS: PALABRAS CLAVE

# Total por empresa y palabra (sumando todos los años)
clave_por_empresa <- conteo_clave %>%
  group_by(empresa, palabra) %>%
  summarise(veces = sum(veces), .groups = "drop")

print(clave_por_empresa, n = 50)


# PALABRAS DISTINTIVAS POR EMPRESAS TF-IDF --------------------------------


# Primero sumo todos los años de cada empresa
palabras_empresa <- conteo_todas %>%
  group_by(empresa, word) %>%
  summarise(n = sum(n), .groups = "drop") %>%
  filter(n >= 10)      

# Calculo el tf-idf 
tfidf <- palabras_empresa %>%
  bind_tf_idf(term = word, document = empresa, n = n)


# Me quedo con las 10 palabras con mayor tf-idf de cada empresa
top_tfidf <- tfidf %>%
  group_by(empresa) %>%
  slice_max(tf_idf, n = 10, with_ties = FALSE) %>%
  ungroup()

print(top_tfidf, n = 150)


# ANÁLISIS DE SENTIMIENTO (LOUGHRAN-McDONALD) -----------------------------


loughran <- get_sentiments("loughran")


total_palabras <- palabras_empresa %>%
  group_by(empresa) %>%
  summarise(total = sum(n), .groups = "drop")

total_palabras

# Cruzo mis palabras con el diccionario: me quedo solo con las que están en él:

sentimientos <- palabras_empresa %>%
  inner_join(loughran, by = "word", relationship = "many-to-many") %>%
  group_by(empresa, sentiment) %>%
  summarise(n = sum(n), .groups = "drop") %>%
  left_join(total_palabras, by = "empresa") %>%
  mutate(proporcion = n / total)      

print(sentimientos, n = 100)

# Gráfico: proporción de cada sentimiento por empresa
grafico_sent <- ggplot(sentimientos, aes(x = sentiment, y = proporcion, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ empresa) +
  coord_flip() +
  labs(title = "Sentimientos en los reportes anuales (Loughran-McDonald)",
       x = "Sentimiento", y = "Proporción del texto")

print(grafico_sent)

# Sentimientos principales:

sentimientos %>%
  group_by(sentiment) %>%
  summarise(n = sum(n), .groups = "drop") %>%
  arrange(desc(n)) %>%
  print()

# Palabras más frecuentes dentro de los sentimientos "negative" y "uncertainty"
palabras_empresa %>%
  inner_join(loughran, by = "word", relationship = "many-to-many") %>%
  filter(sentiment %in% c("negative", "uncertainty")) %>%
  group_by(sentiment, word) %>%
  summarise(n = sum(n), .groups = "drop") %>%
  group_by(sentiment) %>%
  slice_max(n, n = 10, with_ties = FALSE) %>%
  print()

# Palabras más frecuentes dentro del sentimiento positivo
palabras_empresa %>%
  inner_join(loughran, by = "word", relationship = "many-to-many") %>%
  filter(sentiment %in% c("positive")) %>%
  group_by(sentiment, word) %>%
  summarise(n = sum(n), .groups = "drop") %>%
  group_by(sentiment) %>%
  slice_max(n, n = 10, with_ties = FALSE) %>%
  print()