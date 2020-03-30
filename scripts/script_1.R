#wÅ‚Ä…czenie bibliotek 
library(tm) 
library (hunspell)
library (stringr)

#zmiana katalogu roboczego 
workDir <- "C:\\Users\\Beniamin\\Desktop\\Nowy folder\\TextMining"
setwd(workDir)

#definicja katalogÃ³w 
inputDir <- ".\\data"
outputDir <- ".\\results"
scriptsDir <- ".\\scripts"
workspaceDir <- ".\\workspaces"

#utworzenie katalogu wyjÅ›ciowego
dir.create(outputDir, showWarnings = FALSE)
dir.create(workspaceDir, showWarnings = FALSE)

#utworzenie korpusu dokumentÃ³w
corpusDir <- paste(
  inputDir,
  "\\",
  "Literatura - streszczenia - oryginal",
  sep = ""
)
corpus <- VCorpus(
  DirSource(
    corpusDir,
    pattern = "*.txt",
    encoding = "UTF-8"
  ),
  readerControl = list(
    language = "pl_PL"
  )
)


#wstÄ™pne przetwarzanie 
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, content_transformer(tolower))
stoplistFile <- paste(
  inputDir,
  "\\",
  "stopwords_pl.txt",
  sep = ""
)
stoplist <- readLines(
  stoplistFile,
  encoding = "UTF-8"
)
corpus <- tm_map(corpus, removeWords, stoplist)
corpus <- tm_map(corpus, stripWhitespace)

remove_char <- content_transformer(
  function(x, pattern, replacement) 
    gsub(pattern, replacement, x)
)

#usuniecie 'em dash' i 3/4 z tekstow
corpus <- tm_map(corpus, remove_char, intToUtf8(8722), "")
corpus <- tm_map(corpus, remove_char, intToUtf8(190), "")

#lemantyzacja - sprowadzanie do formy podstawowej 
polish <- dictionary(lang = "pl_PL")

lemmatize <- function(text) {
  simple_text <- str_trim(as.character(text[1]))
  parsed_text <- strsplit(simple_text, split = " ")
  new_text_vec <- hunspell_stem(parsed_text[[1]], dict = polish)
  for (i in 1:length(new_text_vec)){
    if (length(new_text_vec[[i]]) == 0) new_text_vec[i] <- parsed_text[[1]][i]
    if (length(new_text_vec[[i]]) > 1) new_text_vec[i] <- new_text_vec[[i]][1]
  }
  new_text <- paste(new_text_vec, collapse = " ")
  return(new_text)
}

corpus <- tm_map(corpus, content_transformer(lemmatize))

#usuniêcie rozszerzeñ z nazw dokumentów
cut_extensions <- function(document) {
  meta(document, "id") <- gsub(pattern = "\\.txt$", "", meta(document, "id"))
  return(document)
}

corpus <- tm_map(corpus, cut_extensions)

#eksport korpusu przetworzonego do plików tekstowych
preprocessed_dir <- paste(
  outputDir,
  "\\",
  "Literatura - streszczenia - przetworzone",
  sep = ""
)
dir.create(preprocessed_dir, showWarnings = FALSE)
writeCorpus(corpus, path = preprocessed_dir)

