todays_date = $(shell date "+%Y-%m-%d")
todays_data = "data/$(todays_date)_jjstache_likes.rds"

all: index.html

$(todays_data): scripts/get_tweets.R
	Rscript $<

index.html: index.Rmd $(todays_data)
	Rscript -e "rmarkdown::render('index.Rmd')"

test:
	echo $(todays_data)

