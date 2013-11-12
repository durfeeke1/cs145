Create Table User(UserID TEXT, Rating Int(8), Location, Country);
Create Table Time(ItemID, Started, Ends);
Create Table Item(ItemID, UserID TEXT, Name, Description, NumberOfBids Int(8));
Create Table Price(ItemID, FirstBid Float(8,2), BuyPrice Float(8,2), Currently Float(8,2));
Create Table Categories(ItemID, Category);
Create Table Bids(ItemID, BidderID TEXT, Time, Amount);

