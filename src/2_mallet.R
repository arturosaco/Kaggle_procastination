library(ProjectTemplate)
load.project()

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


con <- file("data/output_mallet/topic-keys.300.txt") 
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

topic.weights <- as.matrix(read.table("data/output_mallet/doc-topics.300.txt"))


munge.tw <- function(dat, row.index){
  dat <- do.call(rbind, lapply(row.index, function(x){
    aux <- dat[x, ]
    cbind(aux[2], aux[-(1:2)][3:(length(aux)-2) %% 2 == 1],
      aux[-(1:2)][3:(length(aux)-2) %% 2 == 0])
  }))

  dat[,1] <- as.character(gsub(".*texts_train/|\\.txt", "", dat[,1]))
  dat <- data.frame(dat, row.names = NULL)
  names(dat) <- c("review_id", "topic", "weight")
  dat$topic <- as.integer(as.character(dat$topic))
  dat$weight <- as.numeric(as.character(dat$weight))

  dat <- join(dat, alphas, by = "topic")
  dat$tf.idf <- dat$weight * -log(dat$alpha)

  features.tf <- dcast(dat, 
    review_id ~ topic, value.var = "weight")
  features.tf.idf <- dcast(dat,
    review_id ~ topic, value.var = "tf.idf")
  names(features.tf)[-1] <- paste("tf", names(features.tf)[-1], sep = ".")
  names(features.tf.idf)[-1] <- paste("tf.idf", names(features.tf.idf)[-1], 
    sep = ".")
  list(features.tf, features.tf.idf)
}


indices <- list()
for(k in 1:183){
  indices[[k]] <- ((k - 1) * 1000 + 1):(k * 1000)
}
indices[[length(indices) + 1]] <- 183001:nrow(topic.weights)

system.time({
out <- mclapply(indices, function(index.sub){
  #print(range(index.sub))
  munge.tw(topic.weights, index.sub)
}, mc.cores = 2)
})

features.tf <- do.call(rbind, lapply(out, function(x) x[[1]] ))
features.tf.idf <- do.call(rbind, lapply(out, function(x) x[[2]] ))
features.tf$review_id <- as.character(features.tf$review_id)
features.tf.idf$review_id <- as.character(features.tf.idf$review_id)

cache("features.tf")
cache("features.tf.idf")


