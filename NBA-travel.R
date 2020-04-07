install.packages('rvest')
install.packages('plyr')
install.packages('dplyr')
install.packages('hash')
install.packages('stringr')
install.packages('car')
install.packages('MASS')

library(rvest)
library(plyr)
library(dplyr)
library(hash)
library(stringr)
library(car)
library(MASS)


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
  
  four.factor.away <- grep(x=game, "pace\"", value=TRUE)[2]
  away.pace <- str_match(four.factor.away, '.*pace\"\\s>(.*?)<.*')[2]
  away.efg <- str_match(four.factor.away, '.*efg_pct\"\\s>(.*?)<.*')[2]
  away.tov <- str_match(four.factor.away, '.*tov_pct\"\\s>(.*?)<.*')[2]
  away.orb <- str_match(four.factor.away, '.*orb_pct\"\\s>(.*?)<.*')[2]
  away.ftprb <- str_match(four.factor.away, '.*ft_rate\"\\s>(.*?)<.*')[2]
  away.ortg <- str_match(four.factor.away, '.*off_rtg\"\\s>(.*?)<.*')[2]

  four.factor.home <- grep(x=game, "pace\"", value=TRUE)[3]
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

#scrape <- rbind(scrape.1, scrape.2, scrape.3, scrape.4, scrape.5, scrape.6, scrape.7, scrape.8, scrape.9, scrape.10)
#write.csv(scrape, "scrape.csv")

scrape <- read.csv(file = 'scrape.csv')

#scape plus travel schedule data from github
merged <- merge(scrape, `2017_18_schedule_travel`, by="code", all.x = FALSE, all.y = TRUE)

#addition of index factors and averages
merged$index.pace <- 0
merged$index.efg <- 0
merged$index.tov <- 0
merged$index.orb <- 0
merged$index.ftprb <- 0
merged$index.ortg <- 0
merged$index.points <- 0

for (i in 1:nrow(merged)) {
  if (merged$home_team[i] == merged$index_team[i]) {
    merged$index.pace[i] <- merged$home.pace[i]
    merged$index.efg[i] <- merged$home.efg[i]
    merged$index.tov[i] <- merged$home.tov[i]
    merged$index.orb[i] <- merged$home.orb[i]
    merged$index.ftprb[i] <- merged$home.ftprb[i]
    merged$index.ortg[i] <- merged$home.ortg[i]
    merged$index.points[i] <- merged$home_team_score[i]
    
  }
  if (merged$away_team[i] == merged$index_team[i]) {
    merged$index.pace[i] <- merged$away.pace[i]
    merged$index.efg[i] <- merged$away.efg[i]
    merged$index.tov[i] <- merged$away.tov[i]
    merged$index.orb[i] <- merged$away.orb[i]
    merged$index.ftprb[i] <- merged$away.ftprb[i]
    merged$index.ortg[i] <- merged$away.ortg[i]
    merged$index.points[i] <- merged$away_team_score[i]
  }
}

for (i in 1:nrow(merged)) {
  merged$index.average.pace[i] <- mean(merged[which(merged$index_team == merged$index_team[i] & merged$season_end_year == merged$season_end_year[i]),32])
  merged$index.average.efg[i] <- mean(merged[which(merged$index_team == merged$index_team[i] & merged$season_end_year == merged$season_end_year[i]),33])
  merged$index.average.tov[i] <- mean(merged[which(merged$index_team == merged$index_team[i] & merged$season_end_year == merged$season_end_year[i]),34])
  merged$index.average.orb[i] <- mean(merged[which(merged$index_team == merged$index_team[i] & merged$season_end_year == merged$season_end_year[i]),35])
  merged$index.average.ftprb[i] <- mean(merged[which(merged$index_team == merged$index_team[i] & merged$season_end_year == merged$season_end_year[i]),36])
  merged$index.average.ortg[i] <- mean(merged[which(merged$index_team == merged$index_team[i] & merged$season_end_year == merged$season_end_year[i]),37])
  merged$ index.average.ppg[i] <- mean(merged[which(merged$index_team == merged$index_team[i] & merged$season_end_year == merged$season_end_year[i]),38])
}

write.csv(merged, "merged.csv")

fit <- lm(Dist_Km ~ index.pace + index.ftprb + index.orb + index.tov + index.efg + index.ortg, data  = merged)
summary(fit)

fit2 <- lm(Dist_Km ~ index.ortg, data = merged)
summary(fit2)

fit3 <- lmer(Dist_Km ~ index.ortg + (1 | season_end_year) + (1 | index_team), data = merged)
summary(fit3)



