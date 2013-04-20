library(ProjectTemplate)
load.project()

data.reviews.biz <- join(data.reviews[,
    c("review_id", "votes.useful", "stars", "date", "business_id", "user_id")],
  data.biz[,
    c("business_id", "open", "review_count", "longitude", "latitude",
      "biz.stars")])

data.rbu <- join(data.reviews.biz,
  data.users[,c("user_id", "average_stars", "user_review_count")])

### Select train ids

data.rbu.1 <- join(data.rbu[data.rbu$review_id %in% train.ids,] , features.tf)