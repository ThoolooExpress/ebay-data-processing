select distinct count(*)
from (
select itemID
from inCategory
group by itemID
having count(itemID) = 4;