library(ProjectTemplate)
load.project()

# =============================
# = Wrapper for model fitting =
# =============================

fit.gbm.wrap <- function(formula, data, int.depth.par, n.min.par, n.par,
  shrinkage.par, cv.folds, save.it = TRUE) {

  int.depth.par <- 4
  n.min.par <- 10
  n.par <- 10
  shrinkage.par <- 0.01
  cv.folds <- 10
  data <- data.rbu
  formu <- as.formula(paste("votes.useful~0+", paste(setdiff(names(data.rbu),
    c("review_id", "votes.useful", "date", "business_id", "user_id")), 
    collapse = "+")))


  mod <- gbm(formula = formu, data = data,
    distribution = "poisson", interaction.depth = int.depth.par,
    n.trees = n.par, shrinkage = shrinkage.par,
    n.minobsinnode = n.min.par, cv.folds = cv.folds)

  out <- list(fit = mod$fit, cv.error = mod$cv.error, 
    relevance = summary(mod, plotit=FALSE))
  if(save.it) {
    path.x <- paste("cache/",
      paste(int.depth.par, n.min.par, n.par, shrinkage.par, sep = "_"),
      ".RData", sep = "")
    save(out, file = path.x)
  }
  out
}

# =============
# = Join data =
# =============

data.reviews.biz <- join(data.reviews[data.reviews$review_id %in% train.ids,
    c("review_id", "votes.useful", "stars", "date", "business_id", "user_id")],
  data.biz[,
    c("business_id", "open", "biz.review_count", "longitude", "latitude",
      "biz.stars")])

data.rbu <- join(data.reviews.biz,
  data.users[,c("user_id", "average_stars", "user_review_count")])

### Select train ids

data.rbu <- join(data.rbu, features.tf)
data.rbu <- join(data.rbu , features.tf.idf)
rm(data.reviews, data.users, data.biz, data.reviews.biz, data.reviews.test,
  data.users.test, features.tf, features.tf.idf)
gc()
# =================
# = Model fitting =
# =================

formu <- as.formula(paste("votes.useful~0+", paste(setdiff(names(data.rbu),
 c("review_id", "votes.useful", "date", "business_id", "user_id")), 
  collapse = "+")))

# parameter.grid <- expand.grid(int.depth.par = 3:8, n.min.par = c(5,10,15),
#   n.par = 10000, cv.folds = 10, shrinkage.par = c(0.1, 0.01))

parameter.grid <- expand.grid(int.depth.par = 3:6, n.min.par = c(5,10,15),
  n.par = 10000, cv.folds = 10, shrinkage.par = c(0.1, 0.01))

results <- mclapply(1:nrow(parameter.grid), function(row.x){
    fit.gbm.wrap(formu, data.rbu,
      int.depth.par = parameter.grid[row.x, "int.depth.par"],
      n.min.par = parameter.grid[row.x, "n.min.par"],
      n.par = parameter.grid[row.x, "n.par"],
      shrinkage.par = parameter.grid[row.x, "shrinkage.par"],
      cv.folds = parameter.grid[row.x, "cv.folds"])
  }, mcores = "Fill this")

# ==========
# = glmnet =
# ==========

formu <- as.formula(paste("votes.useful~0+", paste(setdiff(names(data.rbu),
 c("review_id", "votes.useful", "date", "business_id", "user_id")), 
  collapse = "+")))

x.mat <- model.matrix(object = formu, data = data.rbu, 
  na.action = "na.pass")
x.mat[is.na(x.mat[,"user_review_count"]), "user_review_count"] <- 0
x.mat[is.na(x.mat[,"average_stars"]), "average_stars"] <- 
  median(x.mat[,"average_stars"], na.rm = TRUE)
mod.cv <- cv.glmnet(x = x.mat, y = data.rbu$votes.useful, family = "poisson",
  alpha = 0.75, nfolds = 10)
mod <- glmnet(x = x.mat, y = data.rbu$votes.useful, family = "poisson",
  alpha = 0.75, lambda = mod.cv$lambda.1se)

median.fit <- median(data.rbu$average_stars, na.rm = T)
cache("median.fit")

