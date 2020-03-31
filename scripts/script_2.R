#wĹ‚Ä…czenie bibliotek 
library(tm) 
library (hunspell)
library (stringr)

#zmiana katalogu roboczego 
workDir <- "C:\\Users\\Beniamin\\Desktop\\Nowy folder\\TextMining"
setwd(workDir)

#definicja katalogĂłw 
inputDir <- ".\\data"
outputDir <- ".\\results"
scriptsDir <- ".\\scripts"
workspaceDir <- ".\\workspaces"

#utworzenie katalogu wyjĹ›ciowego
dir.create(outputDir, showWarnings = FALSE)
dir.create(workspaceDir, showWarnings = FALSE)

#utworzenie korpusu dokumentĂłw
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

#tu jeszcze usuniecie rozszerzen 
#usunięcie rozszerzeń z nazw dokumentów
cut_extensions <- function(document) {
  meta(document, "id") <- gsub(pattern = "\\.txt$", "", meta(document, "id"))
  return(document)
}

corpus <- tm_map(corpus, cut_extensions)

#utworzenie macierz czestosci

