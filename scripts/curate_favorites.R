library(rtweet)
library(dplyr)
library(progress)

rtweet::auth_setup_default()
user <- "_juliejane"

# a tweet id posted at a target date
# old_tweet_id <- "1273262315677396994"
# likes <- get_favorites(user, n = 1000, retryonratelimit = TRUE)
# old_tweet_id <- tail(likes$status_id, 1)
likes <- get_favorites(user, n = 1000, max_id = old_tweet_id)
range(likes$created_at)

# exclude likes where you've fav'ed multiple from the same screen name
dt <- likes %>%
  group_by(screen_name) %>%
  add_tally()

test <- dt %>%
  distinct(screen_name, n) %>%
  arrange(desc(n))
hist(test$n)
head(test, n = 20)

bad_accounts <- c("ReclaimMSU", "AOC", "BernieSanders", "reallifecomics",
                  "GradEmpUnion", "GravelInstitute", "People4Bernie", "_pem_pem",
                  "itsbirdemic", "JuniperLSimonis")

dt <- dt %>%
  dplyr::filter(n <= 6 | screen_name %in% bad_accounts)
nrow(dt)
old_tweet_id <- tail(likes$status_id, 1)


# likes[nrow(likes),]

pb <- progress_bar$new(total = length(dt$status_id),
                       format = "unfavoriting [:bar] :percent",
                       clear = FALSE,
                       width = 80, show_after = 0)

delete_fav <- function(x){
  Sys.sleep(0.4)
  pb$tick()
  tryCatch(invisible(
    post_favorite(x, destroy = TRUE)
    ), error = function(e) NULL)
}

sapply(dt$status_id, function(x){
  delete_fav(x)
})
