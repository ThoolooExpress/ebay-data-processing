#!/bin/sh
# Purpose:           This script runs the python code and SQL necessary to get
#                    the database ready for use. This script expects the JSON
#                    files to be in the folder ebay_data in the project root,
#                    and will attempt to read all *.json files in that folder

# outputs should provide adequate documentation, hence very sparse comments

if [ ! -d ebay_data ]; then
  echo "ebay_data directory does not exist! Aborting!";
  echo "Please try again with the JSON files in a directory called ebay_data";
  echo "in the project root.";
  exit 2;
fi


echo "ebay_data directory found";

if [ ! -d tmp ]; then
  echo "tmp directory does not exist, creating in project root";
  mkdir tmp;
else
  echo "tmp directory found, clearing all files";
  rm -r tmp;
  mkdir tmp;
fi

echo "Running create.sql";
sqlite3 tmp/ebay-data.db < src/sql/create.sql;

echo "Running import.py, which will import data, set current time,";
echo "and turn on foriegn keys";

python3 src/py/import.py ebay_data/*.json

echo "Success importing data! Now running integrityQueries.sql";

# No output from queries means success
if [[ $(sqlite3 tmp/ebay-data.db < src/sql/integrityQueries.sql) ]]; then
  echo "Imported data did not pass integrity checks! Aborting.";
  exit 2;
fi

echo "Data passed integrity checks, now adding triggers";

sqlite3 tmp/ebay-data.db < src/sql/maketriggers.sql;

echo "Triggers added.  Database is now ready for testing."

echo "Database file is tmp/ebay-data.db";

echo "All triggers can be dropped with the src/sql/dropTriggers.sql file"
