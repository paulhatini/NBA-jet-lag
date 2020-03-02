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
  "Brooklyn Nets" = "BKN",
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

for (i in 1:length(NBAref)) {
  NBAref$Date[i] <- toString(NBAref$Date[i])
}

NBAref$Date <- str_replace_all(NBAref$Date, "[[:punct:]]", "")

NBAref$Code <- paste0(NBAref$Date, "0", NBAref$Home.Neutral)

head(NBAref)

code <- "201210300CLE"

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

test <- do.call(rbind, apply(as.array(head(NBAref$Code)), 1, feature.scraper))
nrow(NBAref)
