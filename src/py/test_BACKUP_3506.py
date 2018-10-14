# File:                       app.py
# Purpose:                    tests for ebay data processing software
# Author:                     Richard G. Morrill
# Created Date:               2018-10-14

import sqlite3
from sqlite3 import OperationalError
import sqlExecFile;
import skeleton_parser

# r:                          runs sql from a file
r = sqlExecFile.sqlExecFile

# parse:                      parses json into .dat files
parse = skeleton_parser.parseJson

# Set up database connection
conn = sqlite3.connect('../../tmp/ebay_data.db')
c = conn.cursor()

# Run query
r(c,'../sql/create.sql')

<<<<<<< HEAD
# Put all data in .dat files
=======
>>>>>>> b7d5859ce578c2094658d6b8fc28c3196b8307c5
for i in range (0,40):
  parse('../../ebay_data/items-%d.json' % i)
