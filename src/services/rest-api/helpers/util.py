import pandas as pd
from flask import current_app
from datetime import datetime

##
# Dump any variable including pandas data STDOUT
##
def var_dump(var):
    debug = current_app.config.get('FLASK_DEBUG')
    if ( debug ):
        pd.set_option('display.max_rows', None)
        pd.set_option('display.max_columns', None)
        pd.set_option('display.width', None)
        pd.set_option('display.max_colwidth', None)
        print(var)

##
# Check valid date format from endpoint
##
def date_validate(date_text):
    try:
        datetime.strptime(date_text, '%Y-%m-%d')
        return True
    except ValueError:
        return False
