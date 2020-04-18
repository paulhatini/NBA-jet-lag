install.packages('rvest')
install.packages('plyr')
install.packages('dplyr')
install.packages('hash')
install.packages('stringr')
install.packages('car')
install.packages('MASS')
install.packages('runner')
install.packages('zoo')
install.packages('data.table')
install.packages('lubridate')

library(rvest)
library(plyr)
library(dplyr)
library(hash)
library(stringr)
library(car)
library(MASS)
library(runner)
library(zoo)
library(data.table)
library(lubridate)

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

#scrape.1 <- do.call(rbind, apply(as.array(NBAref$Code[1:1000]), 1, feature.scraper))
#scrape.2 <- do.call(rbind, apply(as.array(NBAref$Code[1001:2000]), 1, feature.scraper))
#scrape.3 <- do.call(rbind, apply(as.array(NBAref$Code[2001:3000]), 1, feature.scraper))
#scrape.4 <- do.call(rbind, apply(as.array(NBAref$Code[3001:4000]), 1, feature.scraper))
#scrape.5 <- do.call(rbind, apply(as.array(NBAref$Code[4001:5000]), 1, feature.scraper))
#scrape.6 <- do.call(rbind, apply(as.array(NBAref$Code[5001:6000]), 1, feature.scraper))
#scrape.7 <- do.call(rbind, apply(as.array(NBAref$Code[6001:7000]), 1, feature.scraper))
#scrape.8 <- do.call(rbind, apply(as.array(NBAref$Code[7001:8000]), 1, feature.scraper))
#scrape.9 <- do.call(rbind, apply(as.array(NBAref$Code[8001:9000]), 1, feature.scraper))
#scrape.10 <- do.call(rbind, apply(as.array(NBAref$Code[9001:9193]), 1, feature.scraper))

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


'''
for (i in 1:nrow(merged)) {
merged$index.average.pace[i] <- mean(merged$index.pace[which(merged$index_team == merged$index_team[i] & merged$season_end_year == merged$season_end_year[i])])
merged$index.average.efg[i] <- mean(merged$index.efg[which(merged$index_team == merged$index_team[i] & merged$season_end_year == merged$season_end_year[i])])
merged$index.average.tov[i] <- mean(merged$index.tov[which(merged$index_team == merged$index_team[i] & merged$season_end_year == merged$season_end_year[i])])
merged$index.average.orb[i] <- mean(merged$index.orb[which(merged$index_team == merged$index_team[i] & merged$season_end_year == merged$season_end_year[i])])
merged$index.average.ftprb[i] <- mean(merged$index.ftprb[which(merged$index_team == merged$index_team[i] & merged$season_end_year == merged$season_end_year[i])])
merged$index.average.ortg[i] <- mean(merged$index.ortg[which(merged$index_team == merged$index_team[i] & merged$season_end_year == merged$season_end_year[i])])
merged$ index.average.ppg[i] <- mean(merged$index.points[which(merged$index_team == merged$index_team[i] & merged$season_end_year == merged$season_end_year[i])])
}
'''

merged$opponent_team <- merged$away_team
for (i in 1:nrow(merged)) {
  if(merged$index_team[i] == merged$away_team[i]) {
    merged$opponent_team[i] <- merged$home_team[i]
  }
}

merged$home <- "home"
for (i in 1:nrow(merged)) {
  if(merged$away_team[i] == merged$index_team[i]) {
    merged$home[i] <- "away"
  }
}

merged$date <- as.Date(merged$start_time)

setDT(merged)[, `:=`(v_minus3 = sum(merged$Dist_Km[merged$index_team == index_team][between(merged$date[merged$index_team == index_team], date-3, date, incbounds = TRUE)]),
                     v_minus7 = sum(merged$Dist_Km[merged$index_team == index_team][between(merged$date[merged$index_team == index_team], date-7, date, incbounds = TRUE)]), 
                     v_minus14 = sum(merged$Dist_Km[merged$index_team == index_team][between(merged$date[merged$index_team == index_team], date-14, date, incbounds = TRUE)])),
              by = c("index_team", "date")][]

merged$timezone <- as.character(merged$timezone)
merged$Prev_timezone <- as.character(merged$Prev_timezone)

merged$timezone[which(merged$timezone == "")] <- "Canada/Toronto"
merged$Prev_timezone[which(merged$Prev_timezone == "")] <- "Canada/Toronto"

for(i in 1:nrow(merged)) {
  if(merged$timezone[i] == "America/New_York" | merged$timezone[i] == "Canada/Toronto" |
     merged$timezone[i] == "America/Detroit" | merged$timezone[i] == "America/Indiana/Indianapolis") {
    merged$timezone[i] <- "ET"
  }
  if(merged$timezone[i] == "America/Chicago") {
    merged$timezone[i] <- "CT"
  }
  if(merged$timezone[i] == "America/Denver") {
    merged$timezone[i] <- "MT"
  }
  if(merged$timezone[i] == "America/Los_Angeles") {
    merged$timezone[i] <- "PT"
  }
  if(merged$timezone[i] == "America/Phoenix") {
    if(dst(as.character(merged$date[i])) == TRUE) {
      merged$timezone[i] <- "PT"
    }
    if(dst(as.character(merged$date[i])) == FALSE) {
      merged$timezone[i] <- "MT"
    }
  }
}


for(i in 1:nrow(merged)) {
  if(merged$Prev_timezone[i] == "America/New_York" | merged$Prev_timezone[i] == "Canada/Toronto" |
     merged$Prev_timezone[i] == "America/Detroit" | merged$Prev_timezone[i] == "America/Indiana/Indianapolis") {
    merged$Prev_timezone[i] <- "ET"
  }
  if(merged$Prev_timezone[i] == "America/Chicago") {
    merged$Prev_timezone[i] <- "CT"
  }
  if(merged$Prev_timezone[i] == "America/Denver") {
    merged$Prev_timezone[i] <- "MT"
  }
  if(merged$Prev_timezone[i] == "America/Los_Angeles") {
    merged$Prev_timezone[i] <- "PT"
  }
  if(merged$Prev_timezone[i] == "America/Phoenix") {
    if(dst(as.character(merged$date[i])) == TRUE) {
      merged$Prev_timezone[i] <- "PT"
    }
    if(dst(as.character(merged$date[i])) == FALSE) {
      merged$Prev_timezone[i] <- "MT"
    }
  }
}

merged$Delta_timezone <- 0
for(i in 1:nrow(merged)) {
  if(merged$Prev_timezone[i] == "ET") {
    if(merged$timezone[i] == "ET") {
      merged$Delta_timezone[i] <- 0
    }
    if(merged$timezone[i] == "CT") {
      merged$Delta_timezone[i] <- 1
    }
    if(merged$timezone[i] == "MT") {
      merged$Delta_timezone[i] <- 2
    }
    if(merged$timezone[i] == "PT") {
      merged$Delta_timezone[i] <- 3
    }
  }
  if(merged$Prev_timezone[i] == "CT") {
    if(merged$timezone[i] == "ET") {
      merged$Delta_timezone[i] <- -1
    }
    if(merged$timezone[i] == "CT") {
      merged$Delta_timezone[i] <- 0
    }
    if(merged$timezone[i] == "MT") {
      merged$Delta_timezone[i] <- 1
    }
    if(merged$timezone[i] == "PT") {
      merged$Delta_timezone[i] <- 2
    }
  }
  if(merged$Prev_timezone[i] == "MT") {
    if(merged$timezone[i] == "ET") {
      merged$Delta_timezone[i] <- -2
    }
    if(merged$timezone[i] == "CT") {
      merged$Delta_timezone[i] <- -1
    }
    if(merged$timezone[i] == "MT") {
      merged$Delta_timezone[i] <- 0
    }
    if(merged$timezone[i] == "PT") {
      merged$Delta_timezone[i] <- 1
    }
  }
  if(merged$Prev_timezone[i] == "PT") {
    if(merged$timezone[i] == "ET") {
      merged$Delta_timezone[i] <- -3
    }
    if(merged$timezone[i] == "CT") {
      merged$Delta_timezone[i] <- -2
    }
    if(merged$timezone[i] == "MT") {
      merged$Delta_timezone[i] <- -1
    }
    if(merged$timezone[i] == "PT") {
      merged$Delta_timezone[i] <- 0
    }
  }
}

for(i in 1:nrow(merged)) {
  if(merged$Prev_timezone[i] == "ET") {
    if(merged$timezone[i] == "ET") {
      merged$Delta_timezone[i] <- "0"
    }
    if(merged$timezone[i] == "CT") {
      merged$Delta_timezone[i] <- "1"
    }
    if(merged$timezone[i] == "MT") {
      merged$Delta_timezone[i] <- "2"
    }
    if(merged$timezone[i] == "PT") {
      merged$Delta_timezone[i] <- "3"
    }
  }
}

for(i in 1:nrow(merged)) {
  if(merged$Prev_timezone[i] == "ET") {
    if(merged$timezone[i] == "ET") {
      merged$Delta_timezone[i] <- 0
    }
    if(merged$timezone[i] == "CT") {
      merged$Delta_timezone[i] <- 1
    }
    if(merged$timezone[i] == "MT") {
      merged$Delta_timezone[i] <- 2
    }
    if(merged$timezone[i] == "PT") {
      merged$Delta_timezone[i] <- 3
    }
  }
}

merged$travel_direction <- "NA"
for(i in 1:nrow(merged)){
  if(merged$Delta_timezone[i] < 0) {
    merged$travel_direction[i] <- "EAST"
  }
  if(merged$Delta_timezone[i] > 0) {
    merged$travel_direction[i] <- "WEST"
  }
}

## a team is jetlagged if : ABS(DELTA_TIMEZONE) >= 2 + DAYS SINCE LAST GAME

merged$jetlag <- FALSE
merged$days_since_last_game <- 0
merged$shift <- 0

for(i in 1:nrow(merged)) {
  merged$days_since_last_game[i] <- as.Date(merged$start_time[i]) - as.Date(merged$Prev_game_start[i])
  merged$shift[i] <- abs(as.numeric(merged$Delta_timezone[i])) - abs(as.numeric(1 + merged$days_since_last_game[i]))
  if(abs(as.numeric(merged$Delta_timezone[i])) >= 1 + merged$days_since_last_game[i]) {
    merged$jetlag[i] <- TRUE
  }
}

test <- merged[which(merged$jetlag == TRUE),c(17,18,43,44,48,50,51)]


dst(tail(merged$date))

dst("2018-09-01")


## need to figure out how to make a jetlag calculation such that jetlag = change in timezone with return to mean by one hour per day

test <- merged[which(index_team == "BOSTON_CELTICS"),c(17,18,43,44,48,50,51)]



hist(merged$Dist_Km)
hist(merged$v_minus3)
hist(merged$v_minus7)
hist(merged$v_minus14)

hist(aggregate(Dist_Km~index_team, merged, sum)[,2])
min(aggregate(Dist_Km~index_team, merged, sum)[,2])
aggregate(Dist_Km~index_team, merged, sum)


write.csv(merged, "merged.csv")
merged <- read.csv(file = "merged.csv")

merged$teamid <- paste0(merged$index_team, '_', merged$season_end_year)
merged$opponentid <- paste0(merged$opponent_team, '_', merged$season_end_year)


fits1 <- lm(index.ortg ~ jetlag + teamid + opponentid, data = merged[which(merged$home == "away"),], family=binomial(link='logit'))
summary(glm.fits1)
fits2 <- lm(index.ortg ~ jetlag + teamid + opponentid, data = merged[which(merged$home == "home"),], family=binomial(link='logit'))
summary(glm.fits2)



fit4 <- lm(index.ortg ~ Dist_Km + teamid, data = merged[which(merged$home == "away"),])
summary(fit4)

fit5 <- lm(index.ortg ~ Dist_Km + teamid, data = merged[which(merged$home == "home"),])
summary(fit5)

fit6 <- lm(index.ortg ~ Dist_Km + teamid, data = merged)
summary(fit6)




fit7 <- lm(index.ortg ~ v_minus3 + teamid + opponentid, data = merged[which(merged$home == "away"),])
summary(fit7)

fit8 <- lm(index.ortg ~ v_minus3 + teamid + opponentid, data = merged[which(merged$home == "home"),])
summary(fit8)

fit9 <- lm(index.ortg ~ Dist_Km + teamid + opponentid, data = merged)
summary(fit9)