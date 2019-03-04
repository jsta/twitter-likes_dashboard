# ---- curate following ----
followers <- get_followers("__jsta")

followees <- get_friends("__jsta")
favs <- read_latest() %>%
  dplyr::select(user_id, created_at, screen_name, text, urls_expanded_url)
bad_followees <- dplyr::filter(followees, !(user_id %in% favs$user_id))
bad_followees <- lookup_users(bad_followees$user_id)
bad_followees <- dplyr::select_if(bad_followees, purrr::negate(is.list))
bad_followees <- dplyr::filter(bad_followees, !(user_id %in% followers$user_id))
bad_followees <- dplyr::mutate(dplyr::group_by(bad_followees, screen_name),
                               user_interactions = sum(followers_count, friends_count))

# View(bad_followees)
res <- dplyr::filter(bad_followees, (statuses_count < 3 &
                                       created_at < "2016-01-01") |
                       (user_interactions < 40 &
                          account_created_at < "2016-01-01" &
                          created_at < "2017-01-01") |
                       is.na(created_at) |
                       created_at < "2017-01-01" |
                       (is.na(url) &
                          is.na(profile_banner_url) &
                          is.na(profile_background_url) &
                          created_at < "2018-01-01"))
# View(res)
sapply(res$user_id, function(x) rtweet::post_unfollow_user(x))
