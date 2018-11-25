# Purpose:                Advances the current time in the database by the number
#                         of seconds specified via the command line arg

import sqlite3
import sys

def main(arg):
  try:
    intVal = int(arg)
  except ValueError:
    print("Argument was not an integer")

  if intVal <= 0:
    print("Time may only advance!")
    sys.exit(2);


  # Initialize DB
  conn = sqlite3.connect("../../tmp/ebay-data.db")
  cur = conn.cursor()

  cur.execute("BEGIN TRANSACTION;")
  cur.execute("UPDATE nowTime SET time=time+?;",[intVal]);
  cur.execute("COMMIT");

if __name__ == '__main__':
  main(sys.argv[1])