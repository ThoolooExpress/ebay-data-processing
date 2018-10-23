# File:                         import.py
# Purpose:                      imports the JSON files into the database
# Note:                         partially based on prof's code

# Current Status:               R. G. M. 2018-10-20 Currently only actually
#                               handles users.  Will be extended to all fields
#                               once it works for users

# Comment Below is Prof's

"""
FILE: skeleton_parser.py
------------------
Skeleton parser for programming project 1. Has useful imports and
functions for parsing, including:

1) Directory handling -- the parser takes a list of eBay json files
and opens each file inside of a loop. You just need to fill in the rest.
2) Dollar value conversions -- the json files store dollar value amounts in
a string like $3,453.23 -- we provide a function to convert it to a string
like XXXXX.xx.
3) Date/time conversions -- the json files store dates/ times in the form
Mon-DD-YY HH:MM:SS -- we wrote a function (transformDttm) that converts to the
for YYYY-MM-DD HH:MM:SS, which will sort chronologically in SQL.

Your job is to implement the parseJson function, which is invoked on each file by
the main function. We create the initial Python dictionary object of items for
you; the rest is up to you!
Happy parsing!
"""

import sys
from json import loads
from re import sub
import sqlite3
import sqlExecFile
from contextlib import ExitStack
import time

r = sqlExecFile.sqlExecFile

columnSeparator = "|"

# Dictionary of months used for date transformation
MONTHS = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',\
'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'}

"""
Returns true if a file ends in .json
"""
def isJson(f):
  return len(f) > 5 and f[-5:] == '.json'

"""
Converts month to a number, e.g. 'Dec' to '12'
"""
def transformMonth(mon):
  if mon in MONTHS:
    return MONTHS[mon]
  else:
    return mon


def transformDttm(dttm):
  # Purpose:                Converts time to UNIX timestamp
  ds = time.strptime(dttm, "%b-%d-%y %H:%M:%S")
  return time.mktime(ds)


def transformDollar(money):
  # Purpose:                Convert a dollar ammount string like "$XXX.xx"
  #                         integer number of cents
  if money == None or len(money) == 0 or money == "NULL":
    return money

  # Easier to understand than regexes
  return int(money.replace("$","").replace(",","").replace(".",""))
  # return int(sub ('.', '',   # This is a lot clearer than regexes
  #   sub('$', '', money)
  # )) * 100

def escapeQuote(string):
  if string == None:
    return string
    return '\"' + sub(r'\"','\"\"',string) + '\"'

"""
Schema of Item table is
Items (ItemID, SellerID, Name, Buy_Price, First_Bid, Currently,
Number_of_Bids, Started, Ends, Description)
"""
def parseItem(dictionary,cur):
  itemID = dictionary["ItemID"]
  name = dictionary["Name"]
  description = dictionary["Description"]
  # Moved these fields to the item, because on the actual ebay site, you set
  # the item location for each listing, it's not associated with the seller's
  # account
  location = dictionary["Location"]
  country = dictionary["Country"]
  buyPrice = transformDollar(dictionary.get("Buy_Price", "NULL"))
  firstBid = transformDollar(dictionary["First_Bid"])
  starts = transformDttm(dictionary["Started"])
  ends = transformDttm(dictionary["Ends"])
  sellerUserId = dictionary["Seller"]["UserID"]
  currentPrice = transformDollar(dictionary["Currently"])
  cur.execute('''
    INSERT OR IGNORE INTO 'item' (itemID,name,description,location,country,
                                  buyPrice,firstBid,starts,ends,sellerUserId,
                                  currentPrice)
    VALUES (?,?,?,?,?,?,?,?,?,?,?);
  ''', [itemID,name,description,location,country,buyPrice,firstBid,starts,ends,
        sellerUserId,currentPrice])



def addUser(userID,rating,cur):
  # Purpose:                            Adds a use to the database
  # Precondition:                       cur must be a valid sqlite3 database
  #                                     cursor, and the preceding arguments
  #                                     must make up a valid user profile
  cur.execute(
    """INSERT OR IGNORE INTO 'user' (userID,rating)
       VALUES (?,?);
    """,
    [userID,
    rating])

# END addUser

def parseUser(dictionary,cur):
  # Purpose:                    Parses in users, using addUser
  bids = dictionary.get("Bids")
  if bids != None:
    for bid in bids:
      bidder = bid["Bid"]["Bidder"]
      userID = bidder["UserID"]
      rating = bidder["Rating"]
      
      # location = escapeQuote(bidder.get("Location", "NULL"))
      
      # country = escapeQuote(bidder.get("Country", "NULL"))
      addUser(userID,rating,cur)

  userID = dictionary["Seller"]["UserID"]
  # print(userID);
  rating = dictionary["Seller"]["Rating"]
  # location = escapeQuote(dictionary.get("Location", "NULL"))
  # print(location)
  # country = escapeQuote(dictionary.get("Country", "NULL"))
  addUser(userID,rating,cur)

"""
Schema of Categories table is
Categories (ItemID, Category)
"""
def parseCategory(dictionary,cur):
  # Purpose:                      Constructs a list of unique categories, then
  #                               links each item with its revevant category
  # First try and add all the relevant categories, if they aren't already
  # in the database, then match up the items to the categories
  for c in dictionary.get("Category"):
    cur.execute('''
      INSERT OR IGNORE INTO category (name)
      VALUES (?);
    ''', [c])
    cur.execute('''
      INSERT OR IGNORE INTO inCategory(itemID,catID)
      VALUES (?1,(SELECT catID FROM category WHERE name = ?2 LIMIT 1));
    ''', [dictionary['ItemID'],c])
  
  # Now link it up with the items

"""
Schema of Bids table is
Bids (ItemID, UserID, Time, Amount)
"""
def parseBids(dictionary,cur):
  bids = dictionary.get("Bids")
  if bids != None:
    for bid in bids:
      itemID = dictionary["ItemID"]
      userID = bid["Bid"]["Bidder"]["UserID"]
      bidTime = transformDttm(bid["Bid"]["Time"])
      price = transformDollar(bid["Bid"]["Amount"])
      cur.execute(''' INSERT INTO bids (itemID,userID,"time",price)
                      VALUES (?,?,?,?);
   ''',[itemID,userID,bidTime,price])

"""
Parses a single json file. Currently, there's a loop that iterates over each
item in the data set. Your job is to extend this functionality to create all
of the necessary SQL tables for your database.
"""
def parseJson(json_file,cur):
  with ExitStack() as stack:
    f = stack.enter_context(open(json_file, 'r'))
    items = loads(f.read())['Items']
    cur.execute("BEGIN TRANSACTION;") 
    for item in items:
      """
      TODO: traverse the items dictionary to extract information from the
      given `json_file' and generate the necessary .dat files to generate
      the SQL tables based on your relation design
      """
      parseItem(item,cur)
      parseCategory(item, cur)
      parseUser(item, cur)
      parseBids(item,cur)

    cur.execute("COMMIT;")

"""
Loops through each json files provided on the command line and passes each file
to the parser
"""
def main(argv):

  if len(argv) < 2:
    print >> sys.stderr, 'Usage: python skeleton_json_parser.py <path to json files>'
    sys.exit(1)
      # loops over all .json files in the argument
  # Initialize DB
  conn = sqlite3.connect("../../tmp/ebay-data.db")
  cur = conn.cursor()
  r(cur,"../sql/create.sql")
  for f in argv[1:]:
    if isJson(f):
      parseJson(f,cur)
      print("Success parsing " + f)

if __name__ == '__main__':
  main(sys.argv)
