--File:                   init.sql
--Purpose:                Attempts to drop all tables, then re-creates them
--Author:                 Richard G. Morrill
--Created Date:           2018-10-14

--Current Status:         R. G. M. 2018-10-20 Added tables to match ER diagram, 
--                        but for now everything but user is commented out for
--                        testing

-- Note about date/times: I decided to use UNIX times, because I'm familiar with
--                        them.  This means that all date/time fields are
--                        of type INTEGER, and record the number of seconds
--                        since 1970-01-01 00:00:00 UTC (R.G.M. 2018-10-20)

-- Note about currency:   In keeping with the way almost all financial software
--                        works, I'm storing monetary values as cents in INTEGER
--                        fields to avoid any potential for floating point
--                        issues.  The conversion to decimal values must be
--                        handled outside the database

DROP TABLE IF EXISTS "inCategory";
DROP TABLE IF EXISTS "category";
DROP TABLE IF EXISTS "bids";
DROP TABLE IF EXISTS "listing";
DROP TABLE IF EXISTS "item";
DROP TABLE IF EXISTS "user";

CREATE TABLE "user" (
  -- Stores each user

  userID TEXT PRIMARY KEY, --     the user's unique username
  rating INTEGER  --              the user's rating
);

CREATE TABLE "item" (
  -- Stores each unique item.  Even if the same item is listed by
  -- different sellers at different times, it is still the same item

  itemID INTEGER PRIMARY KEY, --  unique item identifier
  name TEXT, --                   the user-friendly name of the item
  description TEXT, --            a more complete description of the item
  location TEXT, --               the item's location
  country TEXT, --                the country the item is located in
  buyPrice INTEGER, --            buy it now price, in whole cents
  firstBid INTEGER, --            first bid price, in whole cents
  starts TEXT, --              auction start date/time
  ends INTEGER, --                auction end date/time
  sellerUserID TEXT, --            the seller of this item
  currentPrice INTEGER,
  CONSTRAINT sellerUserID
  FOREIGN KEY(sellerUserID) REFERENCES "user"(userID)
);

CREATE TABLE "bids" (
  -- Records each bid, by one user on one item

  userID TEXT, --                 the user bidding on the item


  itemID INTEGER, --           the listing that has been bid on


  "time" INTEGER, --              the date/time the bid was placed

  price INTEGER, --                the bid price, in whole cents

  CONSTRAINT itemID
  FOREIGN KEY (itemID) REFERENCES "item"(itemID),
  CONSTRAINT userID
  FOREIGN KEY (userID) REFERENCES "user"(userID),

  PRIMARY KEY (userID,itemID,"time") -- A given user may only place one bid
                                        -- on a given listing, at a given time,
                                        -- hence this is our primary key

-- Note:  A user could theoretically place multiple bids at the same time due to
--        network latency, or that multiple users could be recorded bidding at
--        the exact same time, for the same reason.  In fact, it is a litle
--        rediculous to imagine only recording times to the nearest second in
--        an application like this.
);

CREATE TABLE "category" (
  -- Stores each category
  name TEXT UNIQUE, --            the name of the category
  catID INTEGER PRIMARY KEY --    sqlite3 alias for ROWID
);

CREATE TABLE "inCategory" (
  -- Records that an item is in a category
  catID INTEGER,
  itemID INTEGER,
  CONSTRAINT itemID
  FOREIGN KEY(itemID) REFERENCES "item"(itemID),
  CONSTRAINT catID
  FOREIGN KEY(catID) REFERENCES "category"(catID),

  PRIMARY KEY (itemID, catID)
)