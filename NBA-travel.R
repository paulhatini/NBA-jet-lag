install.packages('rvest')
install.packages('plyr')
install.packages('dplyr')
install.packages('hash')
install.packages('stringr')

library(rvest)
library(plyr)
library(dplyr)
library(hash)
library(stringr)

rm(list=ls())

years = c(2013:2019)
months = c('october', 'november', 'december', 'january', 'february', 'march', 'april', 'may', 'june')
urls = list()

for (i in 1:length(years)) {
  for (j in 1:length(months)) {
  url = paste0('https://www.basketball-reference.com/leagues/NBA_',years[i],'_games-',months[j],'.html')
  urls[[(i-1)*9+j]] = url
  }
}

tbl = list()
years = 2010
j = 1

length(urls)

for (j in seq_along(urls)) {
  tbl[[j]] = urls[[j]] %>%
    read_html() %>%
    html_nodes("table") %>%
    html_table()
  j = j+1
}

NBAref = ldply(tbl, data.frame)
NBAref <- NBAref[1:6]
NBAref <- NBAref[-which(NBAref$Visitor.Neutral == "Playoffs"),]

NBAref <- NBAref[1:6]

levels(as.factor(NBAref$Visitor.Neutral))

NBAdict <- hash(
  "Atlanta Hawks" = "ATL",
  "Boston Celtics" = "BOS",
  "Brooklyn Nets" = "BRK",
  "Charlotte Bobcats" = "CHA",
  "Charlotte Hornets" = "CHO",
  "Chicago Bulls" = "CHI",
  "Cleveland Cavaliers" = "CLE",
  "Dallas Mavericks" = "DAL",
  "Denver Nuggets" = "DEN",
  "Detroit Pistons" = "DET",
  "Golden State Warriors" = "GSW",
  "Houston Rockets" = "HOU",
  "Indiana Pacers" = "IND",
  "Los Angeles Clippers" = "LAC",
  "Los Angeles Lakers" = "LAL",
  "Memphis Grizzlies" = "MEM",
  "Miami Heat" = "MIA",
  "Milwaukee Bucks" = "MIL",
  "Minnesota Timberwolves" = "MIN",
  "New Orleans Hornets" = "NOH",
  "New Orleans Pelicans" = "NOP",
  "New York Knicks" = "NYK",
  "Oklahoma City Thunder" = "OKC",
  "Orlando Magic" = "ORL",
  "Philadelphia 76ers" = "PHI",
  "Phoenix Suns" = "PHO",
  "Portland Trail Blazers" = "POR",
  "Sacramento Kings" = "SAC",
  "San Antonio Spurs" = "SAS",
  "Toronto Raptors" = "TOR",
  "Utah Jazz" = "UTA",
  "Washington Wizards" = "WAS"
)

for (i in 1:nrow(NBAref)) {
  NBAref$Visitor.Neutral[i] <- NBAdict[[NBAref$Visitor.Neutral[i]]]
  NBAref$Home.Neutral[i] <- NBAdict[[NBAref$Home.Neutral[i]]]
}

NBAref$Date <- as.Date(NBAref$Date, "%a, %b %d, %Y")

for (i in 1:nrow(NBAref)) {
  NBAref$Code[i] <- toString(NBAref$Date[i])
}

NBAref$Code <- str_replace_all(NBAref$Code, "[[:punct:]]", "")

NBAref$Code <- paste0(NBAref$Code, "0", NBAref$Home.Neutral)

feature.scraper <- function(code){
  code <- toString(code)
  url <- paste0('https://www.basketball-reference.com/boxscores/',code,'.html')
  game <- readLines(url)
  
  four.factor.away <- grep(x=game, "pace", value=TRUE)[4]
  away.pace <- str_match(four.factor.away, '.*pace\"\\s>(.*?)<.*')[2]
  away.efg <- str_match(four.factor.away, '.*efg_pct\"\\s>(.*?)<.*')[2]
  away.tov <- str_match(four.factor.away, '.*tov_pct\"\\s>(.*?)<.*')[2]
  away.orb <- str_match(four.factor.away, '.*orb_pct\"\\s>(.*?)<.*')[2]
  away.ftprb <- str_match(four.factor.away, '.*ft_rate\"\\s>(.*?)<.*')[2]
  away.ortg <- str_match(four.factor.away, '.*off_rtg\"\\s>(.*?)<.*')[2]

  four.factor.home <- grep(x=game, "pace", value=TRUE)[5]
  home.pace <- str_match(four.factor.home, '.*pace\"\\s>(.*?)<.*')[2]
  home.efg <- str_match(four.factor.home, '.*efg_pct\"\\s>(.*?)<.*')[2]
  home.tov <- str_match(four.factor.home, '.*tov_pct\"\\s>(.*?)<.*')[2]
  home.orb <- str_match(four.factor.home, '.*orb_pct\"\\s>(.*?)<.*')[2]
  home.ftprb <- str_match(four.factor.home, '.*ft_rate\"\\s>(.*?)<.*')[2]
  home.ortg <- str_match(four.factor.home, '.*off_rtg\"\\s>(.*?)<.*')[2]
  
  row <- data.frame(code, 
                    away.pace, away.efg, away.tov, away.orb, away.ftprb, away.ortg, 
                    home.pace, home.efg, home.tov, home.orb, home.ftprb, home.ortg,
                    stringsAsFactors = FALSE)
  return(row)
}

celtics.subset <- NBAref[which(NBAref$Visitor.Neutral == "BOS" | NBAref$Home.Neutral == "BOS"),]
celtics.subset <- subset(celtics.subset, Date > "2017-08-01" & Date < "2018-08-01")
cs.scrape <- do.call(rbind, apply(as.array(celtics.subset$Code), 1, feature.scraper))
write.csv(cs.scrape, "cs.scrape.csv")


scrape.1 <- do.call(rbind, apply(as.array(NBAref$Code[1:1000]), 1, feature.scraper))
scrape.2 <- do.call(rbind, apply(as.array(NBAref$Code[1001:2000]), 1, feature.scraper))
scrape.3 <- do.call(rbind, apply(as.array(NBAref$Code[2001:3000]), 1, feature.scraper))
scrape.4 <- do.call(rbind, apply(as.array(NBAref$Code[3001:4000]), 1, feature.scraper))
scrape.5 <- do.call(rbind, apply(as.array(NBAref$Code[4001:5000]), 1, feature.scraper))
scrape.6 <- do.call(rbind, apply(as.array(NBAref$Code[5001:6000]), 1, feature.scraper))
scrape.7 <- do.call(rbind, apply(as.array(NBAref$Code[6001:7000]), 1, feature.scraper))
scrape.8 <- do.call(rbind, apply(as.array(NBAref$Code[7001:8000]), 1, feature.scraper))
scrape.9 <- do.call(rbind, apply(as.array(NBAref$Code[8001:9000]), 1, feature.scraper))
scrape.10 <- do.call(rbind, apply(as.array(NBAref$Code[9001:9193]), 1, feature.scraper))

nrow(NBAref)

scrape <- rbind(scrape.1, scrape.2, scrape.3, scrape.4, scrape.5, scrape.6, scrape.7, scrape.8, scrape.9, scrape.10)
write.csv(scrape, "scrape.csv")



celtics_travel_test <- read.csv("celtics_travel_test.csv")
names(celtics_travel_test)[16] <- "Code"
celtics_merged_test <- merge(celtics.subset, celtics_travel_test, by="Code", all.x = TRUE)
#write.csv(celtics_merged_test, "celtics_merged_test.csv")

usc <- read.csv("uscities.csv", stringsAsFactors=FALSE)

typeof(usc$city)
usc$city[1]
celtics_merged_test$home_city

usc$timezomes <- toString(usc$timezone)

for (i in 1:nrow(celtics_merged_test)) {
  celtics_merged_test$game.tz[i] <- usc[which(usc$city == toString(celtics_merged_test$home_city[i]) & usc$state_name == toString(celtics_merged_test$home_state[i])),][16]
}



head(celtics_merged_test)
usc[which(usc$city == toString(celtics_merged_test$home_city[2]) & usc$state_name == "Massachusetts"),][16]







names(scrape)[2] <- "Code"
merged <- merge(scrape, NBAref, by="Code", all.x = FALSE)
merged$season <- 0

for (i in 1:nrow(merged)) {
  if(merged$Date[i] > "2012-10-02" && merged$Date[i] < "2013-10-01") {
    merged$season[i] <- "2013"
  }
  if(merged$Date[i] > "2013-10-02" && merged$Date[i] < "2014-10-01") {
    merged$season[i] <- "2014"
  }
  if(merged$Date[i] > "2014-10-02" && merged$Date[i] < "2015-10-01") {
    merged$season[i] <- "2015"
  }
  if(merged$Date[i] > "2015-10-02" && merged$Date[i] < "2016-10-01") {
    merged$season[i] <- "2016"
  }
  if(merged$Date[i] > "2016-10-02" && merged$Date[i] < "2017-10-01") {
    merged$season[i] <- "2017"
  }
  if(merged$Date[i] > "2017-10-02" && merged$Date[i] < "2018-10-01") {
    merged$season[i] <- "2018"
  }
  if(merged$Date[i] > "2018-10-02" && merged$Date[i] < "2019-10-01") {
    merged$season[i] <- "2019"
  }
}

tail(merged)

abrev <- c("ATL", "BOS", "BRK", "CHA", "CHO", "CHI", "CLE", "DAL", "DEN", "DET", "GSW", "HOU",
           "IND", "LAC", "LAL", "MEM", "MIA", "MIL", "MIN", "NOH", "NOP", "NYK", "OKC", "ORL", 
           "PHI", "PHO", "POR", "SAC", "SAS", "TOR", "UTA", "WAS")


for(i in 1:length(abrev)) { 
  nam <- paste(abrev[i], ".subset", sep = "")
  assign(nam, merged[which(merged$Visitor.Neutral == abrev[i] | merged$Home.Neutral == abrev[i]),])
}





