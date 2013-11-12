Select Count (*) From (Select Distinct Category From Categories, Price, Bids Where Price.ItemID=Bids.ItemID and Categories.ItemID = Price.ItemID and Currently > 100);

