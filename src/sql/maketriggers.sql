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