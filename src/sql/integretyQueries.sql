-- Purpose:  Contains queries that verify all the constraints,
--           to test them before pasting them into the triggers

-- Returns any items that have a current price that dosen't match the highest bid
SELECT * FROM item
WHERE currentPrice <> (SELECT MAX(price) FROM bids WHERE item.itemID = bids.itemID);