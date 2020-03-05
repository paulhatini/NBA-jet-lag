import basketball_reference_web_scraper
from basketball_reference_web_scraper import client
from basketball_reference_web_scraper.data import Team
import pandas as pd
import csv
from datetime import datetime, timedelta
import mpu

coords_df = pd.read_csv("~/Downloads/uscities.csv")

schedule = pd.DataFrame(client.season_schedule(season_end_year=2018))
schedule['start_time'] = schedule['start_time'] - timedelta(hours=4, minutes=0)

schedule.home_team = schedule.home_team.astype(str)
schedule.away_team = schedule.away_team.astype(str)

schedule.home_team = [x.replace('Team.', '') for x in schedule.home_team]
schedule.away_team = [x.replace('Team.', '') for x in schedule.away_team]

# Define team name dictionary
city_dict = {'CLEVELAND_CAVALIERS': 'Cleveland', 
             'GOLDEN_STATE_WARRIORS': 'San Francisco', 
             'DETROIT_PISTONS': 'Detroit',
             'INDIANA_PACERS': 'Indianapolis', 
             'ORLANDO_MAGIC': 'Orlando', 
             'WASHINGTON_WIZARDS': 'Washington',
             'BOSTON_CELTICS': 'Boston', 
             'MEMPHIS_GRIZZLIES': 'Memphis', 
             'DALLAS_MAVERICKS': 'Dallas',
             'UTAH_JAZZ': 'Salt Lake City', 
             'SAN_ANTONIO_SPURS': 'San Antonio',
             'PHOENIX_SUNS': 'Phoenix', 
             'SACRAMENTO_KINGS': 'Sacramento', 
             'TORONTO_RAPTORS': 'Toronto',
             'OKLAHOMA_CITY_THUNDER': 'Oklahoma City', 
             'LOS_ANGELES_LAKERS': 'Los Angeles',
             'CHARLOTTE_HORNETS': 'Charlotte', 
             'MILWAUKEE_BUCKS': 'Milwaukee', 
             'PHILADELPHIA_76ERS': 'Philadelphia',
             'BROOKLYN_NETS': 'Brooklyn', 
             'MINNESOTA_TIMBERWOLVES': 'Minneapolis',
             'NEW_ORLEANS_PELICANS': 'New Orleans', 
             'CHICAGO_BULLS': 'Chicago',
             'HOUSTON_ROCKETS': 'Houston', 
             'MIAMI_HEAT': 'Key Biscayne', 
             'NEW_YORK_KNICKS': 'Manhattan',
             'DENVER_NUGGETS': 'Denver', 
             'LOS_ANGELES_CLIPPERS': 'Los Angeles',
             'PORTLAND_TRAIL_BLAZERS': 'Portland', 
             'ATLANTA_HAWKS': 'Atlanta'}
state_dict = {'CLEVELAND_CAVALIERS': 'Ohio', 
              'GOLDEN_STATE_WARRIORS': 'California',
              'DETROIT_PISTONS': 'Michigan',
              'INDIANA_PACERS': 'Indiana', 
              'ORLANDO_MAGIC': 'Florida', 
              'WASHINGTON_WIZARDS': 'District of Columbia',
              'BOSTON_CELTICS': 'Massachusetts', 
              'MEMPHIS_GRIZZLIES': 'Tennessee', 
              'DALLAS_MAVERICKS': 'Texas',
              'UTAH_JAZZ': 'Utah', 
              'SAN_ANTONIO_SPURS': 'Texas',
              'PHOENIX_SUNS': 'Arizona', 
              'SACRAMENTO_KINGS': 'California', 
              'TORONTO_RAPTORS': 'Canada',
              'OKLAHOMA_CITY_THUNDER': 'Oklahoma', 
              'LOS_ANGELES_LAKERS': 'California',
              'CHARLOTTE_HORNETS': 'North Carolina', 
              'MILWAUKEE_BUCKS': 'Wisconsin',
              'PHILADELPHIA_76ERS': 'Pennsylvania',
              'BROOKLYN_NETS': 'New York', 
              'MINNESOTA_TIMBERWOLVES': 'Minnesota',
              'NEW_ORLEANS_PELICANS': 'Louisiana', 
              'CHICAGO_BULLS': 'Illinois',
              'HOUSTON_ROCKETS': 'Texas', 
              'MIAMI_HEAT': 'Florida', 
              'NEW_YORK_KNICKS': 'New York',
              'DENVER_NUGGETS': 'Colorado', 
              'LOS_ANGELES_CLIPPERS': 'California',
              'PORTLAND_TRAIL_BLAZERS': 'Oregon', 
              'ATLANTA_HAWKS': 'Georgia'}
team_abbv_dict = {
              "ATLANTA_HAWKS": "ATL",
              "BOSTON_CELTICS": "BOS",
              "BROOKLYN_NETS": "BKN",
              "CHARLOTTE_BOBCATS": "CHA",
              "CHARLOTTE_HORNETS": "CHO",
              "CHICAGO_BULLS": "CHI",
              "CLEVELAND_CAVALIERS": "CLE",
              "DALLAS_MAVERICKS": "DAL",
              "DENVER_NUGGETS": "DEN",
              "DETROIT_PISTONS": "DET",
              "GOLDEN_STATE_WARRIORS": "GSW",
              "HOUSTON_ROCKETS": "HOU",
              "INDIANA_PACERS": "IND",
              "LOS_ANGELES_CLIPPERS": "LAC",
              "LOS_ANGELES_LAKERS": "LAL",
              "MEMPHIS_GRIZZLIES": "MEM",
              "MIAMI_HEAT": "MIA",
              "MILWAUKEE_BUCKS": "MIL",
              "MINNESOTA_TIMBERWOLVES": "MIN",
              "NEW_ORLEANS_HORNETS": "NOH",
              "NEW_ORLEANS_PELICANS": "NOP",
              "NEW_YORK_KNICKS": "NYK",
              "OKLAHOMA_CITY_THUNDER": "OKC",
              "ORLANDO_MAGIC": "ORL",
              "PHILADELPHIA_76ERS": "PHI",
              "PHOENIX_SUNS": "PHO",
              "PORTLAND_TRAIL_BLAZERS": "POR",
              "SACRAMENTO_KINGS": "SAC",
              "SAN_ANTONIO_SPURS": "SAS",
              "TORONTO_RAPTORS": "TOR",
              "UTAH_JAZZ": "UTA",
              "WASHINGTON_WIZARDS": "WAS"
}

schedule['home_team_abbv'] = 0
schedule['home_city'] = 0
schedule['home_state'] = 0
# Fix team names and abbreviations based on dictionary
schedule['home_city'] = schedule['home_team'].map(city_dict)
schedule['home_state'] = schedule['home_team'].map(state_dict)
schedule['home_team_abbv'] = schedule['home_team'].map(team_abbv_dict)


boston_check = schedule[(schedule['home_team'] == "BOSTON_CELTICS") |
                        (schedule['away_team'] == "BOSTON_CELTICS")].reset_index(drop=True)


def attach_coordinates(df, coordinate_data):
    coordinate_select = coordinate_data[['city', 'state_name', 'lat', 'lng']]
    new_df = pd.merge(df, coordinate_select, left_on=['home_city', 'home_state'], right_on=['city', 'state_name'])
    new_df = new_df.sort_values(by='start_time')
    return new_df


full_df = attach_coordinates(boston_check, coords_df).reset_index(drop=True)
# missed = boston_check[~boston_check['start_time'].isin(full_df['start_time'])]
# working_df_use = working_data_all[~working_data_all['Ticker'].isin(bad_tickers)].reset_index(drop=True)



full_df['Prev_lat'] = full_df["lat"].shift(1)
full_df['Prev_lng'] = full_df["lng"].shift(1)
full_df.loc[full_df['Prev_lat'].isnull(), 'Prev_lat'] = full_df['lat']
full_df.loc[full_df['Prev_lng'].isnull(), 'Prev_lng'] = full_df['lng']

full_df["Dist_Km"] = full_df.apply(lambda x:
                                   mpu.haversine_distance((x['Prev_lat'], x['Prev_lng']),
                                                          (x['lat'], x['lng'])), axis=1)
full_df['Dist_Mi'] = full_df['Dist_Km']*(5/8)

full_df['code'] = 0
full_df['code'] = full_df['start_time'].dt.strftime('%Y%m%d') + str(0) + full_df['home_team_abbv']

del full_df['city'], full_df['state_name']
full_df.to_csv("~/Downloads/celtics_travel_test.csv")
