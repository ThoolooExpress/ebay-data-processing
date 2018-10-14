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

# Get the sql query file
fd = open('../sql/init.sql','r')
init_sql = fd.read()
fd.close()
# Break it into commands
sqlCommands = init_sql.split(';')

# Set up database connection
conn = sqlite3.connect('../../tmp/ebay_data.db')
c = conn.cursor()

# Run all the commands in the file

for command in sqlCommands:
  try:
    c.execute(command)
  except(OperationalError, msg):
    print("Error in command: ", msg)
