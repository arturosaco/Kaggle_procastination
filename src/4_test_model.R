library(ProjectTemplate)
load.project()

data.reviews.biz.test <- join(data.reviews[data.reviews$review_id %in% test.ids,
    c("review_id",  "stars", "date", "business_id", "user_id", "votes.useful")],
  data.biz[,
    c("business_id", "open", "biz.review_count", "longitude", "latitude",
      "biz.stars")])

data.rbu.test <- join(data.reviews.biz.test,
  data.users[,c("user_id", "average_stars", "user_review_count")])

### Select train ids

data.rbu.test <- join(data.rbu.test, features.tf.test)
data.rbu.test <- join(data.rbu.test , features.tf.idf.test)

data.rbu.test[is.na(data.rbu.test$user_review_count), "user_review_count"] <- 0
data.rbu.test[is.na(data.rbu.test$average_stars), "average_stars"] <- median.fit

gc()

formu <- as.formula(paste("review_id~0+", paste(setdiff(names(data.rbu.test),
 c("review_id", "date", "business_id", "user_id", "votes.useful")), 
  collapse = "+")))

x.mat <- model.matrix(object = formu, data = data.rbu.test, 
  na.action = na.pass)

preds <- predict(mod.glmnet, newx = x.mat, type = "response")
actual <- data.rbu.test[, "votes.useful"]

sqrt(mean((log1p(preds) - log1p(actual))^2))
plot(preds, actual)