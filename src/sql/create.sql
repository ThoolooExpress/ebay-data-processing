--File:                   init.sql
--Purpose:                Attempts to drop all tables, then re-creates them
--Author:                 Richard G. Morrill
--Created Date:           2018-10-14

--Current Status:         R.G.M. 2018-10-14 This is just a test schema, I'm
--                        only representing a very small portion of the data
--                        with this schema

DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS item;
-- DROP TABLE IF EXISTS listing;
-- DROP TABLE IF EXISTS bid;

CREATE TABLE user (
  user_id VARCHAR PRIMARY KEY,
  rating INTEGER
);

CREATE TABLE item (
  item_id INTEGER PRIMARY KEY,
  name VARCHAR
)