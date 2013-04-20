library(ProjectTemplate)
load.project()

# =============================
# = Wrapper for model fitting =
# =============================

fit.gbm.wrap <- function(formula, data, int.depth.par, n.min.par, n.par,
  shrinkage.par, cv.folds, save.it = TRUE) {

  # int.depth.par <- 4
  # n.min.par <- 10
  # n.par <- 10
  # shrinkage.par <- 0.01
  # cv.folds <- 10

  mod <- gbm(formula = formu, data = data.rbu.2,
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

data.reviews.biz <- join(data.reviews[,
    c("review_id", "votes.useful", "stars", "date", "business_id", "user_id")],
  data.biz[,
    c("business_id", "open", "biz.review_count", "longitude", "latitude",
      "biz.stars")])

data.rbu <- join(data.reviews.biz,
  data.users[,c("user_id", "average_stars", "user_review_count")])

### Select train ids

data.rbu.1 <- join(data.rbu[data.rbu$review_id %in% train.ids,] , features.tf)
data.rbu.2 <- join(data.rbu.1 , features.tf.idf)

# =================
# = Model fitting =
# =================

formu <- as.formula(paste("votes.useful~0+", paste(setdiff(names(data.rbu.2),
 c("review_id", "votes.useful", "date", "business_id", "user_id")), 
  collapse = "+")))

parameter.grid <- expand.grid(int.depth.par = 3:8, n.min.par = c(5,10,15),
  n.par = 10000, cv.folds = 10, shrinkage.par = c(0.1, 0.01))

results <- mclapply(1:nrow(parameter.grid), function(row.x){
    fit.gbm.wrap(formu, data.rbu.2,
      int.depth.par = parameter.grid[row.x, "int.depth.par"],
      n.min.par = parameter.grid[row.x, "n.min.par"],
      n.par = parameter.grid[row.x, "n.par"],
      shrinkage.par = parameter.grid[row.x, "shrinkage.par"],
      cv.folds = parameter.grid[row.x, "cv.folds"])
  })