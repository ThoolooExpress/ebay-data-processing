select itemID
from (
select itemID, max(currentPrice) 
from item);