import basketball_reference_web_scraper
from basketball_reference_web_scraper import client
from basketball_reference_web_scraper.data import Team
import pandas as pd
import csv
from datetime import datetime, timedelta
import mpu

# Define team city, state, abbreviation dictionary
city_dict = {
    'ATLANTA_HAWKS': 'Atlanta',
    'BOSTON_CELTICS': 'Boston',
    'BROOKLYN_NETS': 'Brooklyn',
    'CHARLOTTE_BOBCATS': 'Charlotte',
    'CHARLOTTE_HORNETS': 'Charlotte',
    'CHICAGO_BULLS': 'Chicago',
    'CLEVELAND_CAVALIERS': 'Cleveland',
    'DALLAS_MAVERICKS': 'Dallas',
    'DENVER_NUGGETS': 'Denver',
    'DETROIT_PISTONS': 'Detroit',
    'GOLDEN_STATE_WARRIORS': 'San Francisco',
    'HOUSTON_ROCKETS': 'Houston',
    'INDIANA_PACERS': 'Indianapolis',
    'LOS_ANGELES_CLIPPERS': 'Los Angeles',
    'LOS_ANGELES_LAKERS': 'Los Angeles',
    'MEMPHIS_GRIZZLIES': 'Memphis',
    'MIAMI_HEAT': 'Key Biscayne',
    'MILWAUKEE_BUCKS': 'Milwaukee',
    'MINNESOTA_TIMBERWOLVES': 'Minneapolis',
    'NEW_ORLEANS_PELICANS': 'New Orleans',
    'NEW_ORLEANS_HORNETS': 'New Orleans',
    'NEW_YORK_KNICKS': 'Manhattan',
    'OKLAHOMA_CITY_THUNDER': 'Oklahoma City',
    'ORLANDO_MAGIC': 'Orlando',
    'PHILADELPHIA_76ERS': 'Philadelphia',
    'PHOENIX_SUNS': 'Phoenix',
    'PORTLAND_TRAIL_BLAZERS': 'Portland',
    'SACRAMENTO_KINGS': 'Sacramento',
    'SAN_ANTONIO_SPURS': 'San Antonio',
    'TORONTO_RAPTORS': 'Toronto',
    'UTAH_JAZZ': 'Salt Lake City',
    'WASHINGTON_WIZARDS': 'Washington'
}
state_dict = {
    'ATLANTA_HAWKS': 'Georgia',
    'BOSTON_CELTICS': 'Massachusetts',
    'BROOKLYN_NETS': 'New York',
    'CHARLOTTE_BOBCATS': 'North Carolina',
    'CHARLOTTE_HORNETS': 'North Carolina',
    'CHICAGO_BULLS': 'Illinois',
    'CLEVELAND_CAVALIERS': 'Ohio',
    'DALLAS_MAVERICKS': 'Texas',
    'DENVER_NUGGETS': 'Colorado',
    'DETROIT_PISTONS': 'Michigan',
    'GOLDEN_STATE_WARRIORS': 'California',
    'HOUSTON_ROCKETS': 'Texas',
    'INDIANA_PACERS': 'Indiana',
    'LOS_ANGELES_CLIPPERS': 'California',
    'LOS_ANGELES_LAKERS': 'California',
    'MEMPHIS_GRIZZLIES': 'Tennessee',
    'MIAMI_HEAT': 'Florida',
    'MILWAUKEE_BUCKS': 'Wisconsin',
    'MINNESOTA_TIMBERWOLVES': 'Minnesota',
    'NEW_ORLEANS_HORNETS': 'Louisiana',
    'NEW_ORLEANS_PELICANS': 'Louisiana',
    'NEW_YORK_KNICKS': 'New York',
    'OKLAHOMA_CITY_THUNDER': 'Oklahoma',
    'ORLANDO_MAGIC': 'Florida',
    'PHILADELPHIA_76ERS': 'Pennsylvania',
    'PHOENIX_SUNS': 'Arizona',
    'PORTLAND_TRAIL_BLAZERS': 'Oregon',
    'SACRAMENTO_KINGS': 'California',
    'SAN_ANTONIO_SPURS': 'Texas',
    'TORONTO_RAPTORS': 'Canada',
    'UTAH_JAZZ': 'Utah',
    'WASHINGTON_WIZARDS': 'District of Columbia'}
team_abbv_dict = {
    'ATLANTA_HAWKS': 'ATL',
    'BOSTON_CELTICS': 'BOS',
    'BROOKLYN_NETS': 'BRK',
    'CHARLOTTE_BOBCATS': 'CHA',
    'CHARLOTTE_HORNETS': 'CHO',
    'CHICAGO_BULLS': 'CHI',
    'CLEVELAND_CAVALIERS': 'CLE',
    'DALLAS_MAVERICKS': 'DAL',
    'DENVER_NUGGETS': 'DEN',
    'DETROIT_PISTONS': 'DET',
    'GOLDEN_STATE_WARRIORS': 'GSW',
    'HOUSTON_ROCKETS': 'HOU',
    'INDIANA_PACERS': 'IND',
    'LOS_ANGELES_CLIPPERS': 'LAC',
    'LOS_ANGELES_LAKERS': 'LAL',
    'MEMPHIS_GRIZZLIES': 'MEM',
    'MIAMI_HEAT': 'MIA',
    'MILWAUKEE_BUCKS': 'MIL',
    'MINNESOTA_TIMBERWOLVES': 'MIN',
    'NEW_ORLEANS_HORNETS': 'NOH',
    'NEW_ORLEANS_PELICANS': 'NOP',
    'NEW_YORK_KNICKS': 'NYK',
    'OKLAHOMA_CITY_THUNDER': 'OKC',
    'ORLANDO_MAGIC': 'ORL',
    'PHILADELPHIA_76ERS': 'PHI',
    'PHOENIX_SUNS': 'PHO',
    'PORTLAND_TRAIL_BLAZERS': 'POR',
    'SACRAMENTO_KINGS': 'SAC',
    'SAN_ANTONIO_SPURS': 'SAS',
    'TORONTO_RAPTORS': 'TOR',
    'UTAH_JAZZ': 'UTA',
    'WASHINGTON_WIZARDS': 'WAS'
}
teams_list = [
    "ATLANTA_HAWKS",
    "BOSTON_CELTICS",
    "BROOKLYN_NETS",
    "CHARLOTTE_BOBCATS",
    "CHARLOTTE_HORNETS",
    "CHICAGO_BULLS",
    "CLEVELAND_CAVALIERS",
    "DALLAS_MAVERICKS",
    "DENVER_NUGGETS",
    "DETROIT_PISTONS",
    "GOLDEN_STATE_WARRIORS",
    "HOUSTON_ROCKETS",
    "INDIANA_PACERS",
    "LOS_ANGELES_CLIPPERS",
    "LOS_ANGELES_LAKERS",
    "MEMPHIS_GRIZZLIES",
    "MIAMI_HEAT",
    "MILWAUKEE_BUCKS",
    "MINNESOTA_TIMBERWOLVES",
    "NEW_ORLEANS_HORNETS",
    "NEW_ORLEANS_PELICANS",
    "NEW_YORK_KNICKS",
    "OKLAHOMA_CITY_THUNDER",
    "ORLANDO_MAGIC",
    "PHILADELPHIA_76ERS",
    "PHOENIX_SUNS",
    "PORTLAND_TRAIL_BLAZERS",
    "SACRAMENTO_KINGS",
    "SAN_ANTONIO_SPURS",
    "TORONTO_RAPTORS",
    "UTAH_JAZZ",
    "WASHINGTON_WIZARDS"
]


years = [2017, 2018]
cols = ['start_time', 'away_team', 'home_team', 'away_team_score', 'home_team_score']
nba_schedule_data = pd.DataFrame(columns=cols)

for y in years:
    schedule = pd.DataFrame(client.season_schedule(season_end_year=y))
    schedule['start_time'] = schedule['start_time'] - timedelta(hours=4, minutes=0)
    schedule.home_team = schedule.home_team.astype(str)
    schedule.away_team = schedule.away_team.astype(str)
    schedule.home_team = [x.replace('Team.', '') for x in schedule.home_team]
    schedule.away_team = [x.replace('Team.', '') for x in schedule.away_team]
    schedule['home_team_abbv'] = 0
    schedule['home_city'] = 0
    schedule['home_state'] = 0
    # Fix team names and abbreviations based on dictionary
    schedule['home_city'] = schedule['home_team'].map(city_dict)
    schedule['home_state'] = schedule['home_team'].map(state_dict)
    schedule['home_team_abbv'] = schedule['home_team'].map(team_abbv_dict)
    for t in teams_list:
        try:
            single_team_df = schedule[(schedule['home_team'] == t) |
                                      (schedule['away_team'] == t)].reset_index(drop=True)
            single_team_df['index_team'] = t
            single_team_df['season_end_year'] = y
            nba_schedule_data = nba_schedule_data.append(single_team_df, ignore_index=True).reset_index(drop=True)
        except (ValueError, KeyError):
            pass

check = nba_schedule_data.sort_values(by=["index_team", "start_time"])


def attach_coordinates(df, coordinate_data):
    coordinate_select = coordinate_data[['city', 'state_name', 'lat', 'lng', 'timezone']]
    new_df = pd.merge(df, coordinate_select, left_on=['home_city', 'home_state'], right_on=['city', 'state_name'])
    new_df = new_df.sort_values(by=['index_team', 'start_time']).reset_index(drop=True)
    new_df['Prev_lat'] = new_df.groupby(["index_team", "season_end_year"])['lat'].shift(1)
    new_df['Prev_lng'] = new_df.groupby(["index_team", "season_end_year"])['lng'].shift(1)
    new_df.loc[new_df['Prev_lat'].isnull(), 'Prev_lat'] = new_df['lat']
    new_df.loc[new_df['Prev_lng'].isnull(), 'Prev_lng'] = new_df['lng']
    new_df["Dist_Km"] = new_df.apply(lambda x:
                                     mpu.haversine_distance((x['Prev_lat'], x['Prev_lng']),
                                                            (x['lat'], x['lng'])), axis=1)
    new_df['Dist_Mi'] = new_df['Dist_Km'] * (5 / 8)
    new_df['code'] = 0
    new_df['code'] = new_df['start_time'].dt.strftime('%Y%m%d') + str(0) + new_df['home_team_abbv']
    del new_df['city'], new_df['state_name']
    return new_df


coords_df = pd.read_csv("~/Downloads/uscities.csv")

full_df = attach_coordinates(nba_schedule_data, coords_df).reset_index(drop=True)

full_df.to_csv("~/Downloads/2017_18_schedule_travel.csv")
