import basketball_reference_web_scraper
from basketball_reference_web_scraper import client
from basketball_reference_web_scraper.data import Team
import pandas as pd
import csv

coords_df = pd.read_csv("~/Downloads/uscities.csv")

schedule = pd.DataFrame(client.season_schedule(season_end_year=2018))
schedule.home_team = schedule.home_team.astype(str)
schedule.away_team = schedule.away_team.astype(str)

schedule.home_team = [x.replace('Team.', '') for x in schedule.home_team]
schedule.away_team = [x.replace('Team.', '') for x in schedule.away_team]

# Define team name dictionary
city_dict = {'CLEVELAND_CAVALIERS': 'Cleveland', 'GOLDEN_STATE_WARRIORS': 'San Francisco', 'DETROIT_PISTONS': 'Detroit',
             'INDIANA_PACERS': 'Indianapolis', 'ORLANDO_MAGIC': 'Orlando', 'WASHINGTON_WIZARDS': 'Washington',
             'BOSTON_CELTICS': 'Boston', 'MEMPHIS_GRIZZLIES': 'Memphis', 'DALLAS_MAVERICKS': 'Dallas',
             'UTAH_JAZZ': 'Salt Lake City', 'SAN_ANTONIO_SPURS': 'San Antonio',
             'PHOENIX_SUNS': 'Phoenix', 'SACRAMENTO_KINGS': 'Sacramento', 'TORONTO_RAPTORS': 'Toronto',
             'OKLAHOMA_CITY_THUNDER': 'Oklahoma City', 'LOS_ANGELES_LAKERS': 'Los Angeles',
             'CHARLOTTE_HORNETS': 'Charlotte', 'MILWAUKEE_BUCKS': 'Milwaukee', 'PHILADELPHIA_76ERS': 'Philadelphia',
             'BROOKLYN_NETS': 'Brooklyn', 'MINNESOTA_TIMBERWOLVES': 'Minnesota',
             'NEW_ORLEANS_PELICANS': 'New Orleans', 'CHICAGO_BULLS': 'Chicago',
             'HOUSTON_ROCKETS': 'Houston', 'MIAMI_HEAT': 'Miami', 'NEW_YORK_KNICKS': 'Manhattan',
             'DENVER_NUGGETS': 'Denver', 'LOS_ANGELES_CLIPPERS': 'Los Angeles',
             'PORTLAND_TRAIL_BLAZERS': 'Portland', 'ATLANTA_HAWKS': 'Atlanta'}
state_dict = {'CLEVELAND_CAVALIERS': 'Ohio', 'GOLDEN_STATE_WARRIORS': 'California', 'DETROIT_PISTONS': 'Michigan',
              'INDIANA_PACERS': 'Indiana', 'ORLANDO_MAGIC': 'Orlando', 'WASHINGTON_WIZARDS': 'District of Columbia',
              'BOSTON_CELTICS': 'Massachusetts', 'MEMPHIS_GRIZZLIES': 'Memphis', 'DALLAS_MAVERICKS': 'Texas',
              'UTAH_JAZZ': 'Utah', 'SAN_ANTONIO_SPURS': 'Texas',
              'PHOENIX_SUNS': 'Arizona', 'SACRAMENTO_KINGS': 'California', 'TORONTO_RAPTORS': 'Canada',
              'OKLAHOMA_CITY_THUNDER': 'Oklahoma', 'LOS_ANGELES_LAKERS': 'California',
              'CHARLOTTE_HORNETS': 'South Carolina', 'MILWAUKEE_BUCKS': 'Wisconsin',
              'PHILADELPHIA_76ERS': 'Pennsylvania',
              'BROOKLYN_NETS': 'New York', 'MINNESOTA_TIMBERWOLVES': 'Minnesota',
              'NEW_ORLEANS_PELICANS': 'Louisiana', 'CHICAGO_BULLS': 'Illinois',
              'HOUSTON_ROCKETS': 'Texas', 'MIAMI_HEAT': 'Miami', 'NEW_YORK_KNICKS': 'New York',
              'DENVER_NUGGETS': 'Colorado', 'LOS_ANGELES_CLIPPERS': 'California',
              'PORTLAND_TRAIL_BLAZERS': 'Oregon', 'ATLANTA_HAWKS': 'Georgia'}

schedule['home_city'] = 0
schedule['home_state'] = 0
# Fix team names and abbreviations based on dictionary
schedule['home_city'] = schedule['home_team'].map(city_dict)
schedule['home_state'] = schedule['home_team'].map(state_dict)

boston_check = schedule[(schedule['home_team'] == "BOSTON_CELTICS") | (schedule['away_team'] == "BOSTON_CELTICS")]


def attach_coordinates(df, coordinate_data):
    coordinate_select = coordinate_data[['city', 'state_name', 'lat', 'lng']]
    new_df = pd.merge(df, coordinate_select, left_on=['home_city', 'home_state'], right_on=['city', 'state_name'])
    new_df = new_df.sort_values(by='start_time')
    return new_df


full_df = attach_coordinates(boston_check, coords_df)

