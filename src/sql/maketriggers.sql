-- Purpose:                         Declares all our triggers

-- 7) Auction end must always be after auction start

BEGIN TRANSACTION;
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
COMMIT;

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