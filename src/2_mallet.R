library(ProjectTemplate)
load.project()

# library(openNLP)
# library(openNLPmodels.en)
# library(mallet)
# library(Rstem)



# ==================================
# = Create split for local testing =
# ==================================

set.seed(902043578)
train.ids <- sample(data.reviews$review_id, round(nrow(data.reviews) * .8))
test.ids <- setdiff(data.reviews$review_id, train.ids)

cache("train.ids")
cache("test.ids")

# =========================
# = Write files to folder =
# =========================

data.rb <- join(data.reviews, data.biz[,c("business_id",
  "name", "tags")])

data.rb$text.aug <- gsub("_@_", " ", 
  paste(data.rb$text, data.rb$tags, data.rb$name))

# for(k in 1:nrow(data.rb)){
#   if(k %% 1000 == 0) print(k)
#   if(data.rb[k,"review_id"] %in% train.ids){
#     path.x <- paste("data/mallet/texts_train/", data.rb[k,"review_id"], 
#      ".txt", sep = "")
#     } else {
#     path.x <- paste("data/mallet/texts_test/", data.rb[k,"review_id"], 
#      ".txt", sep = "")
#     }
#   write.table(file = path.x,
#     data.rb[k,"text.aug"], quote = FALSE, row.names = FALSE,
#     col.names = FALSE)
# }


# ==============
# = Run mallet =
# ==============

no.topics <- 300
mallet.call.fit <- paste("sh src/run_mallet_fit.sh", no.topics)
system(mallet.call.fit)

mallet.call.test <- paste("sh src/run_mallet_test.sh", no.topics)
system(mallet.call.test)


# ====================
# = Read mallet data =
# ====================

topic.weights <- as.matrix(read.table("data/output_mallet/infer-topic.weights.250.txt"))

topic.weights <- do.call(rbind, lapply(1:nrow(topic.weights), function(x){
  aux <- topic.weights[x, ]
  cbind(aux[2], aux[-(1:2)][3:(length(aux)-2) %% 2 == 1],
    aux[-(1:2)][3:(length(aux)-2) %% 2 == 0])
}))
topic.weights[,1] <- gsub("./data/mallet/texts_test/|\\.txt", "", topic.weights[,1])
topic.weights <- data.frame(topic.weights, row.names = NULL)
names(topic.weights) <- c("review_id", "topic", "weight")
topic.weights$topic <- as.integer(as.character(topic.weights$topic))
topic.weights$weight <- as.numeric(as.character(topic.weights$weight))


con <- file("data/output_mallet/topic-keys.250.txt") 
open(con)
results.list <- list();
current.line <- 1
while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0) {
    results.list[[current.line]] <- strsplit(line, split = "\\t")
    current.line <- current.line + 1
} 
close(con)

alphas <- ldply(results.list, function(x){
    data.frame(topic = as.numeric(x[[1]][1]),
      alpha = x[[1]][2])
  })
alphas$topic <- as.integer(round(alphas$topic))
alphas$alpha <- as.numeric(as.character(alphas$alpha))

topic.weights.1 <- join(topic.weights, alphas)
topic.weights.1$tf.idf <- topic.weights.1$weight * -log(topic.weights.1$alpha)

features.tf <- dcast(topic.weights.1, review_id ~ topic, value.var = "weight")
gc()
features.tf.idf <- dcast(topic.weights.1, review_id ~ topic, value.var = "tf.idf")

names(features.tf)[-1] <- paste("tf", names(features.tf)[-1], sep = ".")
names(features.tf.idf)[-1] <- paste("tf.idf", names(features.tf.idf)[-1], 
  sep = ".")

cache("features.tf")
cache("features.tf.idf")


