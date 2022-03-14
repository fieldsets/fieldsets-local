from flask import current_app
from leaderboard import player, advanced, approach, discipline, batted, standard, overview
from flask_restful import Resource
import os
import psycopg2
import logging
import json as json
import pandas as pd

# Endpoint Handlers
class Schedule(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, game_date):
        pl_host = os.getenv('PL_DB_HOST')
        pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
        pl_user = os.getenv('PL_DB_USER')
        pl_password = os.getenv('PL_DB_PW')
        db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
        cursor = db_connection.cursor()
        cursor.execute("SELECT * from schedule where game_date = %s", [game_date])
        rows = cursor.fetchall()
        colnames = [desc[0] for desc in cursor.description]
        daily_schedule = pd.DataFrame(rows, columns = colnames)
        db_connection.close()
        json_response = json.loads(daily_schedule.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class AdvancedPitcher(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, start_date = "None", end_date="None", year="None", month="None", half="None"):

        if(start_date != "None" and end_date != "None"):
            result = advanced.ArbitraryPitcher(start_date, end_date)
        elif(year != "None"):
            if(month != "None" and half == "None"):
                result = advanced.MonthlyPitcher(year, month)
            elif(month == "None" and half in ["First", "Second"]):
                result = advanced.HalfPitcher(year, half)
            elif(month == "None" and half == "None"):
                result = advanced.AnnualPitcher(year)
            else:
                return {'status': 'Incorrect Yearly Submission'}
        else:
            return {'status': 'Incorrect Submission'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class AdvancedHitter(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, start_date = "None", end_date="None", year="None", month="None", half="None"):

        if(start_date != "None" and end_date != "None"):
            result = advanced.ArbitraryHitter(start_date, end_date)
        elif(year != "None"):
            if(month != "None" and half == "None"):
                result = advanced.MonthlyHitter(year, month)
            elif(month == "None" and half in ["First", "Second"]):
                result = advanced.HalfHitter(year, half)
            elif(month == "None" and half == "None"):
                result = advanced.AnnualHitter(year)
            else:
                return {'status': 'Incorrect Yearly Submission'}
        else:
            return {'status': 'Incorrect Submission'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class AdvancedPitchType(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, start_date = "None", end_date="None", year="None", month="None", half="None"):

        if(start_date != "None" and end_date != "None"):
            result = advanced.ArbitraryPitchType(start_date, end_date)
        elif(year != "None"):
            if(month != "None" and half == "None"):
                result = advanced.MonthlyPitchType(year, month)
            elif(month == "None" and half in ["First", "Second"]):
                result = advanced.HalfPitchType(year, half)
            elif(month == "None" and half == "None"):
                result = advanced.AnnualPitchType(year)
            else:
                return {'status': 'Incorrect Yearly Submission'}
        else:
            return {'status': 'Incorrect Submission'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class ApproachPitcher(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, start_date = "None", end_date="None", year="None", month="None", half="None"):

        if(start_date != "None" and end_date != "None"):
            return {'status': 'Not Implemented'}
        elif(year != "None"):
            if(month != "None" and half == "None"):
                result = approach.MonthlyPitcher(year, month)
            elif(month == "None" and half in ["First", "Second"]):
                result = approach.HalfPitcher(year, half)
            elif(month == "None" and half == "None"):
                result = approach.AnnualPitcher(year)
            else:
                return {'status': 'Incorrect Yearly Submission'}
        else:
            return {'status': 'Incorrect Submission'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class ApproachHitter(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, start_date = "None", end_date="None", year="None", month="None", half="None"):

        if(start_date != "None" and end_date != "None"):
            result = approach.ArbitraryHitter(start_date, end_date)
        elif(year != "None"):
            if(month != "None" and half == "None"):
                result = approach.MonthlyHitter(year, month)
            elif(month == "None" and half in ["First", "Second"]):
                result = approach.HalfHitter(year, half)
            elif(month == "None" and half == "None"):
                result = approach.AnnualHitter(year)
            else:
                return {'status': 'Incorrect Yearly Submission'}
        else:
            return {'status': 'Incorrect Submission'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class ApproachPitchType(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, start_date = "None", end_date="None", year="None", month="None", half="None"):

        if(start_date != "None" and end_date != "None"):
            return {'status': 'Not Implemented'}
        elif(year != "None"):
            if(month != "None" and half == "None"):
                result = approach.MonthlyPitchType(year, month)
            elif(month == "None" and half in ["First", "Second"]):
                result = approach.HalfPitchType(year, half)
            elif(month == "None" and half == "None"):
                result = approach.AnnualPitchType(year)
            else:
                return {'status': 'Incorrect Yearly Submission'}
        else:
            return {'status': 'Incorrect Submission'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class DisciplinePitcher(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, start_date = "None", end_date="None", year="None", month="None", half="None"):

        if(start_date != "None" and end_date != "None"):
            return {'status': 'Not Implemented'}
        elif(year != "None"):
            if(month != "None" and half == "None"):
                result = discipline.MonthlyPitcher(year, month)
            elif(month == "None" and half in ["First", "Second"]):
                result = discipline.HalfPitcher(year, half)
            elif(month == "None" and half == "None"):
                result = discipline.AnnualPitcher(year)
            else:
                return {'status': 'Incorrect Yearly Submission'}
        else:
            return {'status': 'Incorrect Submission'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class DisciplineHitter(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, start_date = "None", end_date="None", year="None", month="None", half="None"):

        if(start_date != "None" and end_date != "None"):
            return {'status': 'Not Implemented'}
        elif(year != "None"):
            if(month != "None" and half == "None"):
                result = discipline.MonthlyHitter(year, month)
            elif(month == "None" and half in ["First", "Second"]):
                result = discipline.HalfHitter(year, half)
            elif(month == "None" and half == "None"):
                result = discipline.AnnualHitter(year)
            else:
                return {'status': 'Incorrect Yearly Submission'}
        else:
            return {'status': 'Incorrect Submission'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class DisciplinePitchType(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, start_date = "None", end_date="None", year="None", month="None", half="None"):

        if(start_date != "None" and end_date != "None"):
            return {'status': 'Not Implemented'}
        elif(year != "None"):
            if(month != "None" and half == "None"):
                result = discipline.MonthlyPitchType(year, month)
            elif(month == "None" and half in ["First", "Second"]):
                result = discipline.HalfPitchType(year, half)
            elif(month == "None" and half == "None"):
                result = discipline.AnnualPitchType(year)
            else:
                return {'status': 'Incorrect Yearly Submission'}
        else:
            return {'status': 'Incorrect Submission'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class BattedPitcher(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, start_date = "None", end_date="None", year="None", month="None", half="None"):

        if(start_date != "None" and end_date != "None"):
            return {'status': 'Not Implemented'}
        elif(year != "None"):
            if(month != "None" and half == "None"):
                result = batted.MonthlyPitcher(year, month)
            elif(month == "None" and half in ["First", "Second"]):
                result = batted.HalfPitcher(year, half)
            elif(month == "None" and half == "None"):
                result = batted.AnnualPitcher(year)
            else:
                return {'status': 'Incorrect Yearly Submission'}
        else:
            return {'status': 'Incorrect Submission'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class BattedHitter(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, start_date = "None", end_date="None", year="None", month="None", half="None"):

        if(start_date != "None" and end_date != "None"):
            return {'status': 'Not Implemented'}
        elif(year != "None"):
            if(month != "None" and half == "None"):
                result = batted.MonthlyHitter(year, month)
            elif(month == "None" and half in ["First", "Second"]):
                result = batted.HalfHitter(year, half)
            elif(month == "None" and half == "None"):
                result = batted.AnnualHitter(year)
            else:
                return {'status': 'Incorrect Yearly Submission'}
        else:
            return {'status': 'Incorrect Submission'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class BattedPitchType(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, start_date = "None", end_date="None", year="None", month="None", half="None"):

        if(start_date != "None" and end_date != "None"):
            return {'status': 'Not Implemented'}
        elif(year != "None"):
            if(month != "None" and half == "None"):
                result = batted.MonthlyPitchType(year, month)
            elif(month == "None" and half in ["First", "Second"]):
                result = batted.HalfPitchType(year, half)
            elif(month == "None" and half == "None"):
                result = batted.AnnualPitchType(year)
            else:
                return {'status': 'Incorrect Yearly Submission'}
        else:
            return {'status': 'Incorrect Submission'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class StandardPitcher(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, start_date = "None", end_date="None", year="None", month="None", half="None"):

        if(start_date != "None" and end_date != "None"):
            return {'status': 'Not Implemented'}
        elif(year != "None"):
            if(month != "None" and half == "None"):
                result = standard.MonthlyPitcher(year, month)
            elif(month == "None" and half in ["First", "Second"]):
                result = standard.HalfPitcher(year, half)
            elif(month == "None" and half == "None"):
                result = standard.AnnualPitcher(year)
            else:
                return {'status': 'Incorrect Yearly Submission'}
        else:
            return {'status': 'Incorrect Submission'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class StandardHitter(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, start_date = "None", end_date="None", year="None", month="None", half="None"):

        if(start_date != "None" and end_date != "None"):
            return {'status': 'Not Implemented'}
        elif(year != "None"):
            if(month != "None" and half == "None"):
                result = standard.MonthlyHitter(year, month)
            elif(month == "None" and half in ["First", "Second"]):
                result = standard.HalfHitter(year, half)
            elif(month == "None" and half == "None"):
                result = standard.AnnualHitter(year)
            else:
                return {'status': 'Incorrect Yearly Submission'}
        else:
            return {'status': 'Incorrect Submission'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class StandardPitchType(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, start_date = "None", end_date="None", year="None", month="None", half="None"):

        if(start_date != "None" and end_date != "None"):
            return {'status': 'Not Implemented'}
        elif(year != "None"):
            if(month != "None" and half == "None"):
                result = standard.MonthlyPitchType(year, month)
            elif(month == "None" and half in ["First", "Second"]):
                result = standard.HalfPitchType(year, half)
            elif(month == "None" and half == "None"):
                result = standard.AnnualPitchType(year)
            else:
                return {'status': 'Incorrect Yearly Submission'}
        else:
            return {'status': 'Incorrect Submission'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class OverviewPitcher(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, start_date = "None", end_date="None", year="None", month="None", half="None"):

        if(start_date != "None" and end_date != "None"):
            return {'status': 'Not Implemented'}
        elif(year != "None"):
            if(month != "None" and half == "None"):
                result = overview.MonthlyPitcher(year, month)
            elif(month == "None" and half in ["First", "Second"]):
                result = overview.HalfPitcher(year, half)
            elif(month == "None" and half == "None"):
                result = overview.AnnualPitcher(year)
            else:
                return {'status': 'Incorrect Yearly Submission'}
        else:
            return {'status': 'Incorrect Submission'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class OverviewHitter(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, start_date = "None", end_date="None", year="None", month="None", half="None"):

        if(start_date != "None" and end_date != "None"):
            return {'status': 'Not Implemented'}
        elif(year != "None"):
            if(month != "None" and half == "None"):
                result = overview.MonthlyHitter(year, month)
            elif(month == "None" and half in ["First", "Second"]):
                result = overview.HalfHitter(year, half)
            elif(month == "None" and half == "None"):
                result = overview.AnnualHitter(year)
            else:
                return {'status': 'Incorrect Yearly Submission'}
        else:
            return {'status': 'Incorrect Submission'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class OverviewPitchType(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, start_date = "None", end_date="None", year="None", month="None", half="None"):

        if(start_date != "None" and end_date != "None"):
            return {'status': 'Not Implemented'}
        elif(year != "None"):
            if(month != "None" and half == "None"):
                result = overview.MonthlyPitchType(year, month)
            elif(month == "None" and half in ["First", "Second"]):
                result = overview.HalfPitchType(year, half)
            elif(month == "None" and half == "None"):
                result = overview.AnnualPitchType(year)
            else:
                return {'status': 'Incorrect Yearly Submission'}
        else:
            return {'status': 'Incorrect Submission'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class Pitcher(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, player_id, leaderboard):

        if(leaderboard in ["Advanced", "Approach", "Discipline", "Batted", "Standard", "Overview"]):
            result = player.Pitcher(player_id, leaderboard)
        else:
            return {'status': 'Incorrect Leaderboard Submitted'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class Hitter(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, player_id, leaderboard):

        if(leaderboard in ["Advanced", "Approach", "Discipline", "Batted", "Standard", "Overview"]):
            result = player.Pitcher(player_id, leaderboard)
        else:
            return {'status': 'Incorrect Leaderboard Submitted'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)


class PitchType(Resource):
    @current_app.cache.cached(timeout=300)
    def get(self, player_id, leaderboard):

        if(leaderboard in ["Advanced", "Approach", "Discipline", "Batted", "Standard", "Overview"]):
            result = player.Pitcher(player_id, leaderboard)
        else:
            return {'status': 'Incorrect Leaderboard Submitted'}

        json_response = json.loads(result.to_json(orient='records', date_format = 'iso'))
        return(json_response)
