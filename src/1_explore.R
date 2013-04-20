library(ProjectTemplate)
load.project()


# =============
# = Read data =
# =============

con <- file('data/yelp_training_set/yelp_training_set_review.json') 
open(con)
results.list <- list();
current.line <- 1
system.time({
while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0 & current.line <=150) {
  if (line != ""){
    results.list[[current.line]] <- do.call(c, fromJSON(line))
    current.line <- current.line + 1
  }
} 
})
close(con)

data.reviews <- data.frame(do.call(rbind, results.list))
data.reviews$text <- iconv(data.reviews$text, "latin1", "UTF-8")
data.reviews$votes.funny <- as.numeric(as.character(data.reviews$votes.funny))
data.reviews$votes.useful <- as.numeric(as.character(data.reviews$votes.useful))
data.reviews$votes.cool <- as.numeric(as.character(data.reviews$votes.cool))
data.reviews$stars <- as.numeric(as.character(data.reviews$stars))
data.reviews$text <- as.character(data.reviews$text)
data.reviews$review_id <- as.character(data.reviews$review_id)

cache("data.reviews")


plot(data.reviews[,c("votes.cool", "votes.funny", "votes.useful", "stars")])

# =======
# = NLP =
# =======

data.sub <- data.reviews[1:1000,]

system.time({
### some symbols might give insights into sentiment, think this through
data.sub$text <- removePunctuation(data.sub$text)
###
#data.sub$text <- removeWords(data.sub$text, stopwords(kind = "en"))
data.sub$text <- tolower(data.sub$text)

tokens <- lapply(1:nrow(data.sub), function(x.row){
  scan_tokenizer(data.sub$text[x.row])
})

stemmed.tokens <- sapply(tokens, wordStem)
})

vocab <- Reduce(union, stemmed.tokens)
vocab.aux <- 1:length(vocab)
names(vocab.aux) <- vocab


# =========================
# = LDA using package lda =
# =========================

documents <- lapply(stemmed.tokens, function(doc.x){
  matrix(0, nrow = 2, ncol = length(doc.x))
  tab <- table(doc.x)
  rbind(as.integer(round(vocab.aux[names(table(doc.x))]) - 1),
    as.integer(round(as.numeric(table(doc.x)))))
})
system.time({
mod <- slda.em(documents = documents, annotations = log1p(data.sub$votes.useful),
  K = 100, variance = var(data.sub$stars), num.e.iterations = 100,
  vocab = vocab, alpha = 0.5, eta = 0.5, regularise = TRUE, lambda = 10,
  params = rep(1,100), num.m.iterations = 100)
})
doc.sums.count <- slda.predict.docsums(documents, topics = mod$topics, 
        alpha = 0.5, eta = 0.5, num.iterations = 1000,
        average.iterations = 5)

props <- t(doc.sums.count)/colSums(doc.sums.count)
preds <- expm1(props %*% mod$coefs)

#plot(preds, data.sub$votes.useful)

sqrt(mean((log1p(preds) - log1p(data.sub$votes.useful))^2))
# =========================
# = LDA using topicmodels =
# =========================
