Select Count(*) From (Select Distinct User.UserID From Item, User,Bids Where Bids.BidderID = Item.UserID and Item.UserID = User.UserID);

