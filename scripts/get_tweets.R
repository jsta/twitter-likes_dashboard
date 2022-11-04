# ---- setup ----
library(rtweet)



if (!is.null(grep("comp", Sys.info()["nodename"]))) { # not on jsta local system
  dashboard_token <- rtweet::rtweet_bot(
    api_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
    api_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
    access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
    access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
  )
  auth_as(dashboard_token)
} else {
  auth_setup_default()
}

read_latest <- function() {
  archives <- list.files("data", pattern = "*likes.rds",
    full.names = TRUE, include.dirs = TRUE)
  dates <- sapply(archives,
    function(x) strsplit(x, "_")[[1]][1])
  dates <- as.Date(
    sapply(dates, function(x) substring(x, nchar(x) - 9, nchar(x))))

  dt <- readRDS(archives[which.max(dates)])
  dt <- data.frame(dt)

  dt <- dplyr::mutate(dt, status_id = dplyr::coalesce(status_id, as.character(id)))
  dt
}

# ---- get tweets ----
outfile <- file.path("data", paste0(Sys.Date(), "_jjstache_likes.rds"))
print(outfile)
if (!file.exists(outfile)) {
  jjstache_likes <- get_favorites("__jsta", n = 1000)
  jjstache_likes <- jjstache_likes[
    order(jjstache_likes$created_at, decreasing = TRUE), ]

  dt <- read_latest()
  i_archive_start <- ifelse( # in case i == 1 has been deleted (#6)
    length(which(jjstache_likes$id_str == dt[1, "status_id"])) == 0,
    which(jjstache_likes$id_str == dt[2, "status_id"]),
    which(jjstache_likes$id_str == dt[1, "status_id"]))
  dt2 <- jjstache_likes[1:i_archive_start, ]

  # dt2 <- dplyr::select(dt2, -media_url, -mentions_screen_name,
  #   -mentions_user_id,
  #   -hashtags)

  dt2$quoted_status_id <- as.character(dt2$quoted_status_id)
  res <- dplyr::bind_rows(dt2, dt)

  saveRDS(res, outfile)
}
