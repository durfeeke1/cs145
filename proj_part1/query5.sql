Select Count(*) From (Select Distinct User.UserID From Item, User Where Rating>1000 and Item.UserID = User.UserID);

