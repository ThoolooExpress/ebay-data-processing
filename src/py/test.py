# Module:                     
# File:                       app.py
# Purpose:                    entry point for ebay data processing application
# Author:                     Richard G. Morrill
# Created Date:               2018-10-14

# Current Status:             R.G.M. 2018-10-14 At this point, all this does
#                             is attempt to create a testing db using the test
#                             schema in ../sql/init.sql, and then populate it
#                             using ../ebay_data/items-0.json

import sqlite3
from sqlite3 import OperationalError
import sqlExecFile;

# r:                          runs sql from a file
r=sqlExecFile.sqlExecFile

# Set up database connection
conn = sqlite3.connect('../../tmp/ebay_data.db')
c = conn.cursor()

# Run query
r(c,'../sql/init.sql')
