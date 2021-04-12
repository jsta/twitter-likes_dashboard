library(rtweet)
library(dplyr)
library(progress)

rtweet::auth_setup_default()
user <- "your_username"

# a tweet id posted at a target date
old_tweet_id <- "an_old_tweet_id"

likes <- get_favorites(user, n = 1000, max_id = old_tweet_id)

# exclude likes where you've fav'ed multiple from the same screen name
dt <- likes %>%
  group_by(screen_name) %>%
  add_tally()

# test <- distinct(dt, screen_name, n)
# hist(test$n)

dt <- dt %>%
  dplyr::filter(n <= 6)

# likes[nrow(likes),]

pb <- progress_bar$new(total = length(dt$status_id),
                       format = "unfavoriting [:bar] :percent",
                       clear = FALSE,
                       width = 80, show_after = 0)

sapply(dt$status_id, function(x){
  Sys.sleep(0.5)
  pb$tick()
  invisible(post_favorite(
    x,
    destroy = TRUE
  ))
})
