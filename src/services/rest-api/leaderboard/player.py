import pandas as pd
import os
import psycopg2
import json
from functools import reduce

def Pitcher(player_id, leaderboard):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()

    if(leaderboard == "Advanced"):
        cursor.execute("select * from leaderboard_annual_advanced_pitcher \
                        where pitchermlbamid = %s", [player_id])
    elif(leaderboard == "Approach"):
        cursor.execute("select * from leaderboard_annual_approach_pitcher \
                        where pitchermlbamid = %s", [player_id])
    elif(leaderboard == "Discipline"):
        cursor.execute("select * from leaderboard_annual_discipline_pitcher \
                        where pitchermlbamid = %s", [player_id])
    elif(leaderboard == "Batted"):
        cursor.execute("select * from leaderboard_annual_batted_pitcher \
                        where pitchermlbamid = %s", [player_id])
    elif(leaderboard == "Standard"):
        cursor.execute("select * from leaderboard_annual_standard_pitcher \
                        where pitchermlbamid = %s", [player_id])
    elif(leaderboard == "Overview"):
        cursor.execute("select * from leaderboard_annual_overview_pitcher \
                        where pitchermlbamid = %s", [player_id])

    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)

def Hitter(player_id, leaderboard):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()

    if(leaderboard == "Advanced"):
        cursor.execute("select * from leaderboard_annual_advanced_hitter \
                        where hittermlbamid = %s", [player_id])
    elif(leaderboard == "Approach"):
        cursor.execute("select * from leaderboard_annual_approach_hitter \
                        where hittermlbamid = %s", [player_id])
    elif(leaderboard == "Discipline"):
        cursor.execute("select * from leaderboard_annual_discipline_hitter \
                        where hittermlbamid = %s", [player_id])
    elif(leaderboard == "Batted"):
        cursor.execute("select * from leaderboard_annual_batted_hitter \
                        where hittermlbamid = %s", [player_id])
    elif(leaderboard == "Standard"):
        cursor.execute("select * from leaderboard_annual_standard_hitter \
                        where hittermlbamid = %s", [player_id])
    elif(leaderboard == "Overview"):
        cursor.execute("select * from leaderboard_annual_overview_hitter \
                        where hittermlbamid = %s", [player_id])

    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)

def PitchType(player_id, leaderboard):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()

    if(leaderboard == "Advanced"):
        cursor.execute("select * from leaderboard_annual_advanced_pitchtype \
                        where pitchermlbamid = %s", [player_id])
    elif(leaderboard == "Approach"):
        cursor.execute("select * from leaderboard_annual_approach_pitchtype \
                        where pitchermlbamid = %s", [player_id])
    elif(leaderboard == "Discipline"):
        cursor.execute("select * from leaderboard_annual_discipline_pitchtype \
                        where pitchermlbamid = %s", [player_id])
    elif(leaderboard == "Batted"):
        cursor.execute("select * from leaderboard_annual_batted_pitchtype \
                        where pitchermlbamid = %s", [player_id])
    elif(leaderboard == "Standard"):
        cursor.execute("select * from leaderboard_annual_standard_pitchtype \
                        where pitchermlbamid = %s", [player_id])
    elif(leaderboard == "Overview"):
        cursor.execute("select * from leaderboard_annual_overview_pitcher_pitchtype \
                        where pitchermlbamid = %s", [player_id])

    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)
