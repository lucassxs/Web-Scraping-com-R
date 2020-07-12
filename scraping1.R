###### EXERCICIO DE WEBSCRAPING ########

library(tidyverse)
library(RSQLite)
library(httr)
library(rvest)

#TABELA DE INTERESSE
url = "https://en.wikipedia.org/wiki/George_E._P._Box"
webpage <-read_html(url)

table <- webpage %>%
html_nodes("table.vcard") %>% #SG
html_table(header = FALSE)
table <-table[[1]]

#Conteúdo da tabela
table %>% as.tibble

#Procurando Links
url = "https://en.wikipedia.org/wiki/List_of_statisticians"
listPages <- read_html(url)
links <- listPages %>%
  html_nodes("body #content") %>% # Inspect Object...
  html_nodes("li") # All links

links

#"Sajid AliKhan,Rawalakot" até"Zipf,GeorgeKingsley"

estatl = links %>%
  as.character %>%
  grep("Sajid Ali Khan, Rawalakot", .)
estatN = links %>%
  as.character%>%
  grep("Zipf, George Kingsley", .)  
estatl

estatN

links <- links[estatl:estatN]

#Páginas Individuais
links

links %>%
  html_nodes("a")

links %>%
   html_nodes("a")  
   html_attr("href") #Salvar title também!  

########### BANCO DE DADOS #####
   li <- links %>% html_nodes("a") %>% html_attr("href")
   li <- paste0("https://en.wikipedia.org", li)
   names <- links %>% html_nodes("a") %>% html_attr("title")
   db = dbConnect(SQLite(),"estatisticos.db")
bad = c("page does not exist", "Florence Nightigale")     
bad1= unlist(sapply(bad, grep, names))
bad2= unlist(sapply(c("mshkhan", "redlink","orghttp"), grep, li))
names= names[-c(bad1, bad2)]
li=li[-c(bad1,bad2)]
dbWriteTable(db, "pérson", data.frame(id=seq_along(names), 
                                      names=names, links=li))
dbExecute(db, "CREATE TABLE info
(id INTEGER, Born TEXT, Died TEXT, AlmaMater TEXT)")

#conferindo o BANCO DE DADOS
dbGetQuery(db,
           "SELECT * FROM person LIMIT 4")
