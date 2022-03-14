import pandas as pd
import os
import psycopg2
import json
from functools import reduce

def MonthlyPitcher(year, month):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_monthly_discipline_pitcher where \
                    year = %s and month = %s", [year, month])
    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)

def HalfPitcher(year, half):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_half_discipline_pitcher where \
                    year = %s and half = %s", [year, half])
    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)

def AnnualPitcher(year):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_annual_discipline_pitcher where \
                    year = %s", [year])
    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)

def MonthlyHitter(year, month):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_monthly_discipline_hitter where \
                    year = %s and month = %s", [year, month])
    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)

def HalfHitter(year, half):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_half_discipline_hitter where \
                    year = %s and half = %s", [year, half])
    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)

def AnnualHitter(year):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_annual_discipline_hitter where \
                    year = %s", [year])
    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)

def MonthlyPitchType(year, month):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_monthly_discipline_pitchtype where \
                    year = %s and month = %s", [year, month])
    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)

def HalfPitchType(year, half):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_half_discipline_pitchtype where \
                    year = %s and half = %s", [year, half])
    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)

def AnnualPitchType(year):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_annual_discipline_pitchtype where \
                    year = %s", [year])
    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)
