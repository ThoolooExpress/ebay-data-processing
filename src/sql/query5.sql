select count(distinct sellerUserID)
from item, user
where item.sellerUserID = user.userID AND user.rating > 1000;