-- Purpose:  Contains queries that verify all the constraints, to be used before
--           enabling triggers and foriegn key constraints.  Note that each of
--           these queries outputs an error message string on failure, and
--           outputs nothing on success.  Also note that these are slow as hell.


-- 1) No duplicate user IDs
--    Query commented to save time because redundant, as primary keys are
--    enforced on import
-- SELECT "Duplicate user ID found!"
-- FROM user AS A, user AS B
-- WHERE A.userID = B.userID AND a.ROWID <> b.ROWID;

-- 2) All sellers / bidders must already be users (This is actually two queries,
--    because doing it in the same query takes over 4 minutes, but the two
--    separate queries can execute in milliseconds.

SELECT "Seller not in user!"
FROM item AS I
WHERE NOT EXISTS (
  SELECT *
  FROM user
  WHERE user.userID = I.sellerUserID
);

SELECT "Bidder not in user!"
FROM bids AS B
WHERE NOT EXISTS (
  SELECT *
  FROM user
  WHERE user.userID = B.userID
);

-- 3) No duplicate item IDs
--    Primary keys are enforced on input

-- SELECT "Duplicate item ID found!"
-- FROM item AS A, item AS B
-- WHERE A.itemID = B.itemID AND A.ROWID <> B.ROWID;

-- 4) Every bid must have a real item

SELECT "Bid does not corrospond to a real item!"
FROM bids
WHERE NOT EXISTS (
  SELECT *
  FROM item
  WHERE item.itemID = bids.itemID
);

-- 5) No empty categories

SELECT "Empty category not allowed!"
FROM category
WHERE NOT EXISTS (
  SELECT *
  FROM inCategory
  WHERE category.catID = inCategory.catID
);

-- 6) No duplicate entries in inCategory
--    No query necessary, primary keys are enforced on import

-- 7) Auction must end after it starts

SELECT "Auction end is not after auction start!"
FROM item
WHERE item.ends <= item.starts;

-- 8) Current price must match highest bid

-- Index used to dramatically speed up this query.  It went from taking 2 mins
-- to less than a second

DROP INDEX IF EXISTS bids_price;
CREATE INDEX bids_price ON bids (itemID,price);
SELECT "Current price does not match highest bid!"
FROM item
WHERE currentPrice <> (SELECT MAX(price) FROM bids WHERE bids.itemID = item.itemID);

-- 9) Bidder may not match seller

SELECT "Self bids not allowed!"
FROM bids
WHERE userID = (SELECT sellerUserID FROM item WHERE item.itemID = bids.itemID);

-- 10) No auction may have two bids at the exact same time

SELECT "No simultaneous bids on the same auction!"
FROM bids AS A, bids AS B
WHERE A.time = B.time AND A.itemID = B.itemID AND A.ROWID <> B.ROWID;

-- 11) No bids before start time or after end time of auction

SELECT "Bid may not be before start time of auction!"
FROM item
WHERE EXISTS (
  SELECT *
  FROM bids
  WHERE "time" < item.starts AND item.itemID = bids.itemID
);

SELECT "Bid may not be after end time of auction!"
FROM item
WHERE EXISTS (
  SELECT *
  FROM bids
  WHERE "time" > item.ends AND item.itemID = bids.itemID
);

-- 12) No user may bid the same ammount on the same item more than once.
--     no query needed, as primary keys are enforced on import

-- 13) The numBids attribute should be correct for each item

SELECT "Incorrect numBids!"
FROM item
WHERE numBids <> (SELECT COUNT() FROM bids WHERE bids.itemID = item.itemID);

-- 14) Every bid must be greater than every older bid on the same item

SELECT "Bids are not strictly ascending!"
FROM item
WHERE EXISTS (
  SELECT *
  FROM bids AS A, bids AS B
  WHERE A.itemID = item.itemID -- Make sure we're looking at the right item
  AND   B.itemID = item.itemID
  AND   A.time > B.time -- A is newer bid
  AND   A.price <= B.price -- not ascending
);

-- 15) Cannot be verified at this time
-- 16) Cannot be verified at this time