# File:                         sqlExecFile.py
# Purpose:                      contains sqlExecFile function and
#                               supporting code
# Author:                       Richard G. Morrill
# Created Date:                 2018-10-14

def sqlExecFile(c,fileName):
  # Purpose:                    Executes all the sql queries in fileName,
  #                             on cursor c
  # @param c:                   The database cursor to run the queries on
  # @param fileName:            The file to source sql queries from

  # Read File
  fd = open(fileName,'r')
  init_sql = fd.read()
  fd.close()

  # Break it into commands
  sqlCommands = init_sql.split(';')

  # Run all the commands in the file
  for command in sqlCommands:
    try:
      c.execute(command)
    except(OperationalError, msg):
      print(
        "Error in file %s, command: " % fileName,
        msg
      )
