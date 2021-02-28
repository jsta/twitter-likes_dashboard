# ---- setup ----
library(rtweet)

if(!grep("comp", Sys.info()["nodename"])){ # not on jsta local system
  dashboard_token <- rtweet::create_token(
    consumer_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
    consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
    access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
    access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
  )
}

read_latest <- function(){
  archives <- list.files("data", pattern = "*likes.rds",
                         full.names = TRUE, include.dirs = TRUE)
  dates <- sapply(archives,
                  function(x) strsplit(x, "_")[[1]][1])
  dates <- as.Date(
    sapply(dates, function(x) substring(x, nchar(x)-9, nchar(x))))

  dt <- readRDS(archives[which.max(dates)])
  dt <- data.frame(dt)
  dt
}

# ---- get tweets ----
outfile <- file.path("data", paste0(Sys.Date(), "_jjstache_likes.rds"))
print(outfile)
if(!file.exists(outfile)){
  jjstache_likes <- get_favorites("__jsta", n = 1000)
  jjstache_likes <- jjstache_likes[
    order(jjstache_likes$created_at, decreasing = TRUE),]

  dt <- read_latest()
  i_archive_start <- ifelse( # in case i == 1 has been deleted (#6)
    length(which(jjstache_likes$status_id == dt[1, "status_id"])) == 0,
    which(jjstache_likes$status_id == dt[2, "status_id"]),
    which(jjstache_likes$status_id == dt[1, "status_id"]))
  dt2 <- jjstache_likes[1:i_archive_start,]

  dt2 <- dplyr::select(dt2, -media_url, -mentions_screen_name,
                       -mentions_user_id,
                       -hashtags)

  res <- dplyr::bind_rows(dt2, dt)

  saveRDS(res, outfile)
}
