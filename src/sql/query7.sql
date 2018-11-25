select count(distinct catID)
from inCategory, bids
where inCategory.itemID = bids.itemID and price > 10000;