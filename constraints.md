Constraints
===========

1.  The user ID is the primary key of the table (create.sql)
 
2.  The in both item and bids, the user ID of the seller and bidder has a foreign
    key constraint (create.sql)
 
3.  The item ID field is the primary key of the item table (create.sql)
 
4.  The item ID field of the bids table has a foreign key constraint (create.sql)
 
5.  There is a trigger that runs when an entry in inCategory is deleted (i.e. an
    item is removed from a category) that deletes the category if there are no
    items left in it (maketriggers.sql)
 
6.  The inCategory table has {itemID, catID} as its primary key, so the same item
    cannot be assigned to a given category more than once (create.sql)
 
7.  There is a trigger that runs after insert on item, that verifies this
    (maketriggers.sql)
 
8.  There is a trigger that runs after insert on bids, that updates currentPrice
    (maketriggers.sql)
 
9.  There is a trigger that runs after insert on bids that verifies this
    (maketriggers.sql)

10. There is a trigger that runs after insert on bids that verifies this
    (maketriggers.sql)

11. There is a trigger that runs after insert on bids that verifies this
    (maketriggers.sql)

12. This is enforced by the primary key of bids (create.sql)

13. There is a trigger that runs on insert on bids that updates numBids
    (maketriggers.sql)

14. This is enforced by a trigger (maketriggers.sql)

15. This is enforced by a trigger (maketriggers.sql)

16. This is enforced by a trigger (maketriggers.sql)