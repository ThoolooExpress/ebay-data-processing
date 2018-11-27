-- Purpose:                         Declares all our triggers

BEGIN TRANSACTION;
-- 6) The items for a given category must exist, so when items are removed
--    from inCategory, remove their corrosponding category if it was the last
--    item

DROP TRIGGER IF EXISTS unused_category;
CREATE TRIGGER unused_category
AFTER DELETE ON inCategory
WHEN NOT EXISTS (
  SELECT *
  FROM inCategory
  WHERE catID = old.catID
)
BEGIN
  DELETE
  FROM category
  WHERE catID = old.catID;
END;
-- 7) Auction end must always be after auction start

DROP TRIGGER IF EXISTS auction_end_after_start;
CREATE TRIGGER auction_end_after_start
AFTER INSERT ON item
FOR EACH ROW
WHEN new.start >= new.end
BEGIN
  SELECT RAISE(ROLLBACK, "An auction must end after it starts!");
END;

-- 8) Current price must match highest bid, so update item when bids are placed

DROP TRIGGER IF EXISTS raise_current_price;
CREATE TRIGGER raise_current_price
AFTER INSERT ON bids
BEGIN
  UPDATE item SET currentPrice = new.price WHERE item.itemID = new.itemID;
END;

-- 9) A user may not bid on an item they are selling

DROP TRIGGER IF EXISTS user_bidder_match;
CREATE TRIGGER user_bidder_match
AFTER INSERT ON bids
WHEN new.userID = (SELECT sellerUserID FROM item WHERE item.itemID = new.itemID LIMIT 1)
BEGIN
  SELECT RAISE(ROLLBACK, "A seller may not bid on their own item!");
END;

-- 10) An auction may not have two bids at the exact same time

DROP TRIGGER IF EXISTS bids_time_match;
CREATE TRIGGER bids_time_match
AFTER INSERT ON bids
WHEN (
  SELECT COUNT()
  FROM bids
  WHERE bids.itemID = new.itemID
  AND bids.time = new.time
) > 1
BEGIN
  SELECT RAISE(ROLLBACK, "No two bids may be submitted on the same item at the same time.");
END;

-- 11) Bids must be within the item's start and end times

DROP TRIGGER IF EXISTS bids_in_auction_time;
CREATE TRIGGER bids_in_auction_time
AFTER INSERT ON bids
WHEN new.time < (SELECT starts FROM item WHERE item.itemID = new.itemID) OR
     new.time > (SELECT ends FROM item WHERE item.itemID = new.itemID)
BEGIN
  SELECT RAISE(ROLLBACK, "Bids must be between the start and end times of the item");
END;

-- 12) No user can make a bid of the same amount to the same item more than once
-- R.G.M. This trigger was replaced by a modification to the primary key of the
-- bids table... sorry Liz...
-- -- since currentPrice has been updated to be the highest bid, bid can't <= the currentPrice which will guarantee it won't equal a previous bid
-- DROP TRIGGER IF EXISTS no_bid_same_amount;
-- CREATE TRIGGER no_bid_same_amount;
-- AFTER INSERT ON bids
-- WHEN new.price <= (SELECT currentPrice FROM item WHERE )
-- BEGIN
-- 	SELECT RAISE(ROLLBACK, “That bid has already been made or is less than the current highest bid! Choose a larger amount.”);
-- END


-- 13) In every auction, the Number of Bids attribute corresponds to the actual number of bids for that particular item

DROP TRIGGER IF EXISTS number_of_bids;
CREATE TRIGGER number_of_bids
AFTER INSERT ON bids
BEGIN
	UPDATE item SET numBids = (
          SELECT COUNT()
				  FROM bids
			    WHERE bids.itemID = new.itemID)
  -- R.G.M. The outer where is necessary, because otherwise we'd be setting
  -- every item to the number of bids of the new item
  WHERE item.itemID = new.itemID;
END;


-- 14) Any new bid for a particular item must have a higher amount than any of
-- the previous bids for that particular item since currentPrice is the highest
-- bid so far..
DROP TRIGGER IF EXISTS new_bid_higher;
CREATE TRIGGER new_bid_higher
AFTER INSERT ON bids
-- WHEN currentPrice <= new.price -- R.G.M. What is currentPrice?  The database
-- engine doesn't know which item we're referring to unless we write a query to
-- tell it
-- New version:
WHEN new.price <= (SELECT currentPrice FROM item WHERE itemID = new.itemID)
BEGIN
	SELECT RAISE(ROLLBACK, "This bid has to be higher than previous bids! Bid higher!");
END;


-- 15) All new bids must be placed at the time which matches the current time of your auction

DROP TRIGGER IF EXISTS new_bid_current_time;
CREATE TRIGGER new_bid_current_time
AFTER INSERT ON bids
WHEN new.time <> (SELECT "time" FROM nowTime)
BEGIN
	SELECT RAISE(ROLLBACK, "Bids must be made at current time!");
END;


-- 16) The current time of your Auction Base system can only advance forward in
-- time, not backward in time

DROP TRIGGER IF EXISTS system_current_time;
CREATE TRIGGER system_current_time
AFTER UPDATE ON nowTime
WHEN old.time >= new.time
BEGIN
	SELECT RAISE(ROLLBACK, "nowTime must always be advanced with updates!");
END;

-- Extra trigger, makes sure that nowTime never has more than one row

DROP TRIGGER IF EXISTS now_time_one_row;
CREATE TRIGGER now_time_one_row
AFTER INSERT ON nowTime
WHEN (SELECT COUNT() FROM nowTime) > 1
BEGIN
  SELECT RAISE(ROLLBACK, "nowTime may never have more than one row!");
END;
COMMIT;
