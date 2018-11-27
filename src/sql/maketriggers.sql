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

-- 12) No user can make a bid of the same amount to the same item more than once

-- since currentPrice has been updated to be the highest bid, bid can't <= the currentPrice which will guarantee it won't equal a previous bid
DROP TRIGGER IF EXISTS no_bid_same_amount;
CREATE TRIGGER no_bid_same_amount;
AFTER INSERT ON bids
WHEN new.price <= currentPrice
BEGIN
	SELECT RAISE(ROLLBACK, “That bid has already been made or is less than the current highest bid! Choose a larger amount.”);
END
COMMIT;

-- 13) In every auction, the Number of Bids attribute corresponds to the actual number of bids for that particular item

-- we don't have a numberOfBids attribute?
DROP TRIGGER IF EXISTS number_of_bids
CREATE TRIGGER number_of_bids
AFTER INSERT ON bids
BEGIN
	UPDATE item SET numberOfBids = (SELECT COUNT()
					         FROM bids
					         WHERE bids.itemID = new.itemID);
END;
COMMIT;

-- 14) Any new bid for a particular item must have a higher amount than any of the previous bids for that particular item

-- since currentPrice is the highest bid so far..
DROP TRIGGER IF EXISTS new_bid_higher
CREATE TRIGGER new_bid_higher
AFTER INSERT ON bids
WHEN currentPrice <= new.price
BEGIN
	SELECT RAISE(ROLLBACK, “This bid has to be higher than previous bids! Bid higher!”);
END;
COMMIT;

-- 15) All new bids must be placed at the time which matches the current time of your auction

DROP TRIGGER IF EXISTS new_bid_current_time
CREATE TRIGGER new_bid_current_time
AFTER INSERT ON bids
WHEN new.time != bids.time  
BEGIN
	UPDATE item SET new.time = bid.time WHERE item.itemID = new.itemID;
END;
COMMIT;

-- 16) The current time of your Auction Base system can only advance forward in time, not backward in time

-- honestly so confused with this one.. bc it's the unix time - shouldn't it just naturally be increasing w/ real time?
DROP TRIGGER IF EXISTS system_current_time
CREATE TRIGGER system_current_time
AFTER INSERT ON nowTime
WHEN bids.time = new.time
BEGIN
	UPDATE nowTime SET new.time = (bid.time+1);
END;
COMMIT;
