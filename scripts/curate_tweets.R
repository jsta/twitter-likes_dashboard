library(rtweet)
library(dplyr)

rtweet::auth_setup_default()
user <- "your_username"

timeline <- get_timeline(user, n = 2000)

dt <- dplyr::filter(timeline, created_at < "2020-11-01")

invisible(sapply(dt[1:nrow(dt),]$status_id, function(x){
  Sys.sleep(0.5)
  rtweet::post_destroy(x)
  }))
