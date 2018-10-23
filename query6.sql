select count(distinct g.userID)
from user g
inner join item i
on g.userID = i.sellerUserID
inner join bids b
on i.sellerUserID = b.userID;