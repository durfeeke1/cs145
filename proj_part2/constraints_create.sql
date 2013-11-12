Create Table User(UserID TEXT, Rating Int(8), Location, Country, primary key (UserID));
Create Table Time(ItemID Int unique references Item(ItemID), Started, Ends, check ( datetime(Started) < datetime(Ends)));
Create Table Item(ItemID Int, UserID TEXT references User(UserID), Name, Description, NumberOfBids Int(8), primary key (ItemID));
Create Table Price(ItemID Int unique references Item(ItemID), FirstBid Float(8,2), BuyPrice Float(8,2), Currently Float(8,2), check (FirstBid <= Currently and Currently <= BuyPrice) );
Create Table Categories(ItemID Int references Item(ItemID), Category);
Create Table Bids(ItemID Int references Item(ItemID), BidderID TEXT references User(UserID), Time, Amount Float(8,2), primary key (ItemID, BidderID, Time), unique (ItemID, Time), unique (ItemID, Amount));
