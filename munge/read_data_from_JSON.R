# library(ProjectTemplate)
# load.project()
#scp -r Desktop/Kaggle.pem Proyectos/Yelp ubuntu@ec2-54-216-0-53.eu-west-1.compute.amazonaws.com:/home/ubuntu

# ====================
# = Read review data =
# ====================

con <- file('data/yelp_training_set/yelp_training_set_review.json') 
open(con)
results.list <- list();
current.line <- 1
system.time({
while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0) {
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
data.reviews$user_id <- as.character(data.reviews$user_id)


cache("data.reviews")


# ===================
# = Read users data =
# ===================

con <- file('data/yelp_training_set/yelp_training_set_user.json') 
open(con)
results.list <- list();
current.line <- 1
system.time({
while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0) {
  if (line != ""){
    results.list[[current.line]] <- do.call(c, fromJSON(line))
    current.line <- current.line + 1
  }
} 
})
close(con)

data.users <- data.frame(do.call(rbind, results.list))
data.users$votes.funny <- as.numeric(as.character(data.users$votes.funny))
data.users$votes.useful <- as.numeric(as.character(data.users$votes.useful))
data.users$votes.cool <- as.numeric(as.character(data.users$votes.cool))
data.users$average_stars <- as.numeric(as.character(data.users$average_stars))
data.users$review_count <- as.numeric(as.character(data.users$review_count))
data.users$user_id <- as.character(data.users$user_id)
names(data.users)[names(data.users) == "review_count"] <- "user_review_count"


cache("data.users")

# =====================
# = Read checkin data =
# =====================

### Not going to use this for the time being

# con <- file('data/yelp_training_set/yelp_training_set_checkin.json') 
# open(con)
# results.list <- list();
# current.line <- 1
# system.time({
# while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0 & current.line <=150) {
#   if (line != ""){
#     results.list[[current.line]] <- do.call(c, fromJSON(line))
#     current.line <- current.line + 1
#   }
# } 
# })
# close(con)

# ========================
# = Read businesses data =
# ========================


con <- file('data/yelp_training_set/yelp_training_set_business.json') 
open(con)
results.list <- list();
current.line <- 1
system.time({
while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0) {
  if (line != ""){
    results.list[[current.line]] <- fromJSON(line)
    current.line <- current.line + 1
  }
} 
})
close(con)

results.list <- lapply(results.list, function(biz.x){
  c(do.call(c,
    biz.x[setdiff(names(biz.x), c("categories", "neighborhoods"))]),
    tags = paste(biz.x[["categories"]], collapse = "_@_"))
})

data.biz <- data.frame(do.call(rbind, results.list))
data.biz$full_address <- iconv(data.biz$full_address, "latin1", "UTF-8")
data.biz$tags <- iconv(data.biz$tags, "latin1", "UTF-8")
data.biz$city <- iconv(data.biz$city, "latin1", "UTF-8")
data.biz$name <- iconv(data.biz$name, "latin1", "UTF-8")
data.biz$stars <- as.numeric(as.character(data.biz$stars))
data.biz$review_count <- as.numeric(as.character(data.biz$review_count))
names(data.biz)[names(data.biz) == "stars"] <- "biz.stars"
cache("data.biz")


# ========================
# = Read test review set =
# ========================

con <- file('data/yelp_test_set/yelp_test_set_review.json') 
open(con)
results.list <- list();
current.line <- 1
system.time({
while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0) {
  if (line != ""){
    results.list[[current.line]] <- do.call(c, fromJSON(line))
    current.line <- current.line + 1
  }
} 
})
close(con)

data.reviews.test <- data.frame(do.call(rbind, results.list))
data.reviews.test$text <- iconv(data.reviews.test$text, "latin1", "UTF-8")
data.reviews.test$stars <- as.numeric(as.character(data.reviews.test$stars))
data.reviews.test$text <- as.character(data.reviews.test$text)
data.reviews.test$review_id <- as.character(data.reviews.test$review_id)

cache("data.reviews.test")



# ========================
# = Read users test data =
# ========================

con <- file('data/yelp_test_set/yelp_test_set_user.json') 
open(con)
results.list <- list();
current.line <- 1
system.time({
while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0) {
  if (line != ""){
    results.list[[current.line]] <- do.call(c, fromJSON(line))
    current.line <- current.line + 1
  }
} 
})
close(con)

data.users.test <- data.frame(do.call(rbind, results.list))
data.users.test$average_stars <- as.numeric(as.character(data.users.test$average_stars))
data.users.test$review_count <- as.numeric(as.character(data.users.test$review_count))
data.users.test$user_id <- as.character(data.users.test$user_id)
names(data.users.test)[names(data.users.test) == "review_count"] <- "user_review_count"

cache("data.users.test")


# =============================
# = Read businesses test data =
# =============================


con <- file('data/yelp_test_set/yelp_test_set_business.json') 
open(con)
results.list <- list();
current.line <- 1
system.time({
while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0) {
  if (line != ""){
    results.list[[current.line]] <- fromJSON(line)
    current.line <- current.line + 1
  }
} 
})
close(con)

results.list <- lapply(results.list, function(biz.x){
  c(do.call(c,
    biz.x[setdiff(names(biz.x), c("categories", "neighborhoods"))]),
    tags = paste(biz.x[["categories"]], collapse = "_@_"))
})

data.biz.test <- data.frame(do.call(rbind, results.list))
data.biz.test$full_address <- iconv(data.biz.test$full_address, "latin1", "UTF-8")
data.biz.test$tags <- iconv(data.biz.test$tags, "latin1", "UTF-8")
data.biz.test$city <- iconv(data.biz.test$city, "latin1", "UTF-8")
data.biz.test$name <- iconv(data.biz.test$name, "latin1", "UTF-8")
data.biz.test$stars <- as.numeric(as.character(data.biz.test$stars))
data.biz.test$review_count <- as.numeric(as.character(data.biz.test$review_count))
names(data.biz.test)[names(data.biz.test) == "stars"] <- "biz.stars"
cache("data.biz.test")
