# Allows user to bid on an item, and buy the item

# To do this, I'll have the user provide their:
# itemID, userID, price (amount they want to bid), and an option to buy

# Incorrect input is taken care of by previous constraints

import argparse
import sqlite3
from prettytable import from_db_cursor

userID_input = raw_input("Enter your userID: ");
itemID_input = raw_input("Enter the itemID of the item you would like to bid on: ");
price_input = raw_input("Enter the amount you would like to place a bid for: ");
buy = raw_input("Would you like to buy if your bid is highest? (y/n): ");

try:
	connection = sqlite3.connect("tmp/ebay-data.db")
	cursor = connection.cursor()  # intial connection

	# when bid is placed, enter it in as a bid for the specific userID and itemID
	new_bid_query = """ INSERT INTO bids (price) VALUES (%s)
						WHERE userID = %r
						AND itemID = %d; """ , % (price_input, userID_input, itemID_input) # putting new price in for bid

	result = cursor.execute(new_bid_query)
	connection.commit()
	print("Bid placed! Let's wait to see what happens..") # (with the auction)
	
	if buy=='y':
		cursor.execute(""" INSERT INTO item (ends) VALUES (time)
						   JOIN item ON nowTime
						   WHERE userID = %r
						   AND itemID = %d; """ , % (userID_input, itemID_input))
		
#if there's an error
except sqlite3.connector.Error as error:
	connection.rollback() #rollback if exception occurred
	print("Failed to place the bid. Either your bid is too low, the auction is closed, or your userID is invalid.")
	
finally:
	#closing the database connection
	if(connection.is_connected()):
		cursor.close()
		connection.close()
		print("sqlite3 connection is closed")
