# Purpose:                  Allows the user to seach based on a variety of
#                           attributes

import argparse
import sqlite3
from prettytable import from_db_cursor

def isInt(s):
  # Purpose:        Helper function to keep try-excepts contained
    try: 
        int(s)
        return True
    except ValueError:
        return False

def parseDollar(arg):
  # Purpose:        Converts any user input dollar ammount into an integer
  #                 number of cents
  if isInt(arg):
    return int(arg)
  return int(arg.replace("$","").replace(",","").replace(".",""))



# def printQuery(itemID=None,category=None,descQuery=None,
#   minPrice=None,maxPrice=None,onlyOpen=False,onlyClosed=False):
#   #Purpsoed:              Prints out a search query to test the argument parser

#   if !itemID:
#     itemID = 0

#   if !category:

#   print("Search Query:")
#   print("itemID %d" % itemID)
#   print("category %s" % category)
#   print("descQuery %s" % descQuery)
#   print("minPrice %d" % minPrice)
#   print("maxPrice %d" % maxPrice)
#   print("open %b" % onlyOpen)
#   print("closed %b" % onlyClosed)

parser = argparse.ArgumentParser(description="Search for items")
parser.add_argument("--itemID",
                    type=int,
                    help="The (integer) itemID to seach for")
parser.add_argument("--category",
                    type=str,
                    help="The category to seach for")
parser.add_argument("--descQuery",
                    type=str,
                    help="The query string to find within the item description")
parser.add_argument("--minPrice",
                    type=str,
                    help="The minimum price (Format as either the (integer) number "
                    "of cents, or as $XXX.xx, number of digits irrelevant)")
parser.add_argument("--maxPrice",
                    type=str,
                    help="The maximum price (Format as either the (integer) number "
                    "of cents, or as XXX.xx (BASH WILL GLITCH IF YOU INCLUDE "
                    "DOLLAR SIGNS), number of digits irrelevant")
parser.add_argument("--open",
                    action="store_true",
                    help="Restrict search to only open auctions")
parser.add_argument("--closed",
                    action="store_true",
                    help="Restrict search to only closed auctions")

args = parser.parse_args()
# printQuery(args.itemID,args.category)

conn = sqlite3.connect("tmp/ebay-data.db")
cur = conn.cursor()

# For each of the conditions, figure out from the args if we actually need it,
# then push them into an array
conds=[]
if args.itemID:
  conds.append("itemID = '{itemID}'".format(itemID = args.itemID))

if args.category:
  conds.append("""
      EXISTS (
        SELECT *
        FROM inCategory JOIN category ON catID
        WHERE itemID = item.itemID AND name LIKE '{category}'
      )
    """.format(category = args.category))

if args.descQuery:
  conds.append("description LIKE '%{descQuery}%'".format(descQuery =  args.descQuery))

if args.minPrice:
  conds.append("currentPrice >= {minPrice}".format(minPrice = parseDollar(args.minPrice)))

if args.maxPrice:
  conds.append("currentPrice <= {maxPrice}".format(maxPrice = parseDollar(args.maxPrice)))

if args.open:
  conds.append("ends < (SELECT time FROM nowTime)")

if args.closed:
  conds.append("ends > (SELECT time FROM nowTime")

queryString = '''SELECT itemID AS "Item ID",
                        SUBSTR(name,0,30) AS Title,
                        SUBSTR(location,0,20) AS Location,
                        country AS Country,
                        PRINTF("$%.2f",buyPrice/100.0) AS "Buy it Now",
                        PRINTF("$%.2f",currentPrice/100.0) AS "Current Price",
                        numBids AS Bids,
                        datetime(starts, 'unixepoch', 'localtime') AS "Start Time",
                        datetime(ends, 'unixepoch', 'localtime') AS "End Time",
                        SUBSTR(sellerUserID,0,10) AS Seller
                     FROM item WHERE '''

# Put all the conditions together
for idx, s in enumerate(conds):
  if idx != 0:
    queryString += " AND "
  queryString += s
queryString += " ORDER BY ends ASC;"

# For debug only
# print(queryString)

# Prettify output
# Print the table

print(from_db_cursor(cur.execute(queryString)))