setwd(choose.dir())
sink("tarea05.txt", split = TRUE)

library(tidyverse)
library(tidytext) 
library(textdata)   
library(lubridate)
library(scales)      
library(topicmodels) 
library(widyr)      
library(igraph)      
library(ggraph)  
# cargar el data sets
datos <- read.csv("DATA-T9-mckinsey-mind-the-gap-articles-20251020.csv", stringsAsFactors = FALSE)
 #vamos a ver que contiene
  glimpse(datos)

  head(datos)
  
 # Ver la estructura del dataset
str(datos)

raw <- read_csv("DATA-T9-mckinsey-mind-the-gap-articles-20251020.csv",
                show_col_types = FALSE) %>%
  select(-1) %>%                       # descarta la columna índice sin nombre
  mutate(doc_id  = row_number(),
         date    = as_date(date),
         year    = year(date),
         n_char  = str_length(article_text)) %>%
  relocate(doc_id)

glimpse(raw)

cat("Documentos:", nrow(raw), "\n")
cat("Rango de fechas:", format(min(raw$date)), "a", format(max(raw$date)), "\n")

raw %>%
  summarise(min_char = min(n_char), media_char = mean(n_char),
            mediana_char = median(n_char), max_char = max(n_char))

ggplot(raw, aes(x = n_char)) +
  geom_histogram(bins = 25, fill = "#2c7fb8", color = "white") +
  labs(title = "Distribución de longitud de los artículos",
       x = "Caracteres por artículo", y = "Cantidad de documentos") +
  theme_minimal()

ggplot(raw, aes(x = date, y = n_char)) +
  geom_point(color = "#2c7fb8") +
  geom_smooth(se = FALSE, color = "firebrick") +
  labs(title = "Longitud de los artículos en el tiempo",
       x = NULL, y = "Caracteres") +
  theme_minimal()

# - El corpus reúne 146 filas y 6 columnas
# - Está enfocado principalmente en analizar hábitos, consumo, inserción laboral,
#   tecnología y tendencias de la Gen Z (Generación Z).
# - Los documentos son altamente comparables: poseen una estructura editorial uniforme,
#   mismo tono analítico, encabezados similares (redactados por Alex Panas y Axel Karlsson)
#   y una extensión parecida entre artículos.

data("stop_words")  

custom_stop <- tibble(word = c("mckinsey", "brought", "you", "welcome",
                               "email", "newsletter", "gap", "mind"))

tidy_articles <- raw %>%
  select(doc_id, title, date, year, article_text) %>%
  unnest_tokens(word, article_text) %>%
  filter(str_detect(word, "[a-z]")) %>%   
  anti_join(stop_words, by = "word") %>%
  anti_join(custom_stop, by = "word")

tidy_articles

# palabras mas frecuentes
tidy_articles %>%
  count(word, sort = TRUE) %>%
  slice_max(n, n = 20) %>%
  ggplot(aes(x = fct_reorder(word, n), y = n)) +
  geom_col(fill = "#2c7fb8") +
  coord_flip() +
  labs(title = "20 palabras más frecuentes en el corpus",
       x = NULL, y = "Frecuencia") +
  theme_minimal()


freq_by_rank <- tidy_articles %>%
  count(word, sort = TRUE) %>%
  mutate(rank = row_number(),
         term_frequency = n / sum(n))

freq_by_rank %>%
  ggplot(aes(x = rank, y = term_frequency)) +
  geom_line(color = "#2c7fb8", linewidth = 1) +
  scale_x_log10() + scale_y_log10() +
  labs(title = "Ley de Zipf: frecuencia de término vs. ranking",
       x = "Rank (log)", y = "Frecuencia del término (log)") +
  theme_minimal()

zipf_fit <- freq_by_rank %>%
  filter(rank < 2000, rank > 10) %>%
  lm(log10(term_frequency) ~ log10(rank), data = .)

# tf idf por año

tfidf_year <- tidy_articles %>%
  count(year, word, sort = TRUE) %>%
  bind_tf_idf(word, year, n) %>%
  arrange(desc(tf_idf))

tfidf_year %>%
  group_by(year) %>%
  slice_max(tf_idf, n = 8, with_ties = FALSE) %>%
  ungroup() %>%
  ggplot(aes(x = fct_reorder(word, tf_idf), y = tf_idf, fill = factor(year))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~year, scales = "free_y") +
  coord_flip() +
  labs(title = "Palabras con mayor tf-idf por año",
       x = NULL, y = "tf-idf") +
  theme_minimal()

# analisis de sentimientos

bing <- get_sentiments("bing")

sentiment_bing <- tidy_articles %>%
  inner_join(bing, by = "word") %>%
  count(doc_id, date, sentiment) %>%
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) %>%
  mutate(net_sentiment = positive - negative)

ggplot(sentiment_bing, aes(x = date, y = net_sentiment)) +
  geom_col(aes(fill = net_sentiment > 0), show.legend = FALSE) +
  scale_fill_manual(values = c("firebrick", "#2c7fb8")) +
  labs(title = "Sentimiento neto por edición (bing: positivas - negativas)",
       x = NULL, y = "Sentimiento neto") +
  theme_minimal()

#sentimiento promedio por edicion
afinn <- get_sentiments("afinn")

sentiment_afinn <- tidy_articles %>%
  inner_join(afinn, by = "word") %>%
  group_by(doc_id, date) %>%
  summarise(avg_sentiment = mean(value), .groups = "drop")

ggplot(sentiment_afinn, aes(x = date, y = avg_sentiment)) +
  geom_point(color = "#2c7fb8") +
  geom_smooth(se = FALSE, color = "firebrick") +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Sentimiento promedio por edición (AFINN, escala -5 a 5)",
       x = NULL, y = "Sentimiento promedio (por palabra)") +
  theme_minimal()


sentiment_bing %>%
  select(doc_id, date, net_sentiment) %>%
  left_join(sentiment_afinn, by = c("doc_id", "date")) %>%
  ggplot(aes(x = net_sentiment, y = avg_sentiment)) +
  geom_point(color = "#2c7fb8") +
  geom_smooth(method = "lm", se = FALSE, color = "firebrick") +
  labs(title = "Comparación bing (neto) vs. AFINN (promedio) por documento",
       x = "Sentimiento neto (bing)", y = "Sentimiento promedio (AFINN)") +
  theme_minimal()

# topic modelling para K=10

word_counts <- tidy_articles %>%
  count(doc_id, word, sort = TRUE)

articles_dtm <- word_counts %>%
  cast_dtm(doc_id, word, n)

articles_dtm

lda_k10 <- LDA(articles_dtm, k = 10, control = list(seed = 1234))

topics_k10 <- tidy(lda_k10, matrix = "beta")

topics_k10 %>%
  group_by(topic) %>%
  slice_max(beta, n = 8, with_ties = FALSE) %>%
  ungroup() %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(x = term, y = beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~topic, scales = "free_y", ncol = 5) +
  scale_x_reordered() +
  coord_flip() +
  labs(title = "Términos principales por tópico (LDA, k = 10)",
       x = NULL, y = expression(beta)) +
  theme_minimal(base_size = 9)

gamma_k10 <- tidy(lda_k10, matrix = "gamma") %>%
  rename(doc_id = document) %>%
  mutate(doc_id = as.integer(doc_id))

# tópico dominante por documento
gamma_k10 %>%
  group_by(doc_id) %>%
  slice_max(gamma, n = 1) %>%
  ungroup() %>%
  left_join(raw %>% select(doc_id, title), by = "doc_id") %>%
  select(doc_id, title, topic, gamma) %>%
  head(10)

# topicos para K=15

lda_k15 <- LDA(articles_dtm, k = 15, control = list(seed = 1234))

topics_k15 <- tidy(lda_k15, matrix = "beta")

topics_k15 %>%
  group_by(topic) %>%
  slice_max(beta, n = 8, with_ties = FALSE) %>%
  ungroup() %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(x = term, y = beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~topic, scales = "free_y", ncol = 5) +
  scale_x_reordered() +
  coord_flip() +
  labs(title = "Términos principales por tópico (LDA, k = 15)",
       x = NULL, y = expression(beta)) +
  theme_minimal(base_size = 9)

# comparacion: con k=10 los tópicos tienden a agrupar temas
#más amplios (consumo, trabajo/carrera, IA, bienestar, finanzas); al subir a
#k=15 esos mismos ejes tienden a subdividirse en variantes más específicas
#(p.ej. "IA en el trabajo" vs. "IA y habilidades"), a costa de tópicos algo
#más redundantes entre sí. Conviene mirar la coherencia de los términos top
#de cada tópico para decidir cuál granularidad es más interpretable para
#este corpus.


# avanzado biogrmas

bigrams <- raw %>%
  select(doc_id, article_text) %>%
  unnest_tokens(bigram, article_text, token = "ngrams", n = 2) %>%
  separate(bigram, into = c("word1", "word2"), sep = " ") %>%
  filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word,
         !word1 %in% custom_stop$word, !word2 %in% custom_stop$word,
         str_detect(word1, "[a-z]"), str_detect(word2, "[a-z]"))

bigram_counts <- bigrams %>%
  count(word1, word2, sort = TRUE)

bigram_counts %>% head(15)

set.seed(2025)

bigram_graph <- bigram_counts %>%
  filter(n >= 4) %>%           # ajustar umbral según densidad del grafo
  graph_from_data_frame()

a <- grid::arrow(type = "closed", length = unit(.1, "inches"))

ggraph(bigram_graph, layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n), arrow = a,
                 end_cap = circle(.05, "inches"), color = "grey60") +
  geom_node_point(color = "#2c7fb8", size = 3) +
  geom_node_text(aes(label = name), vjust = 1, hjust = 1, size = 3) +
  scale_edge_width(range = c(0.3, 1.5)) +
  labs(title = "Red de bigrams más frecuentes (n >= 4)") +
  theme_void()

# biogrmas con negacion

negation_words <- c("not", "no", "never", "without", "cant", "cannot",
                    "dont", "isnt", "wont")

negated_bigrams <- raw %>%
  select(doc_id, article_text) %>%
  unnest_tokens(bigram, article_text, token = "ngrams", n = 2) %>%
  separate(bigram, into = c("word1", "word2"), sep = " ") %>%
  filter(word1 %in% negation_words) %>%
  inner_join(afinn, by = c("word2" = "word")) %>%
  count(word1, word2, value, sort = TRUE) %>%
  mutate(contribution = n * value)

# palabras cuyo sentimiento se ve más "revertido" por ir precedidas de negación
negated_bigrams %>%
  group_by(word2) %>%
  summarise(total_contribution = sum(contribution), .groups = "drop") %>%
  slice_max(abs(total_contribution), n = 20) %>%
  mutate(word2 = fct_reorder(word2, total_contribution)) %>%
  ggplot(aes(x = word2, y = total_contribution, fill = total_contribution > 0)) +
  geom_col(show.legend = FALSE) +
  scale_fill_manual(values = c("firebrick", "#2c7fb8")) +
  coord_flip() +
  labs(title = "Palabras cuyo sentimiento AFINN se revierte tras una negación",
       x = NULL,
       y = "Contribución al sentimiento (n x valor AFINN)") +
  theme_minimal()

sink()
