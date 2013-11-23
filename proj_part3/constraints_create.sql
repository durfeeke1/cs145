Create Table User(UserID TEXT, Rating Int(8), Location TEXT, Country TEXT, primary key (UserID));
Create Table ItemTime(ItemID Int unique references Item(ItemID), Started TEXT, Ends TEXT,  check (datetime(Started) < datetime(Ends)) );
Create Table Item(ItemID Int, UserID TEXT references User(UserID), Name TEXT, Description TEXT, NumberOfBids Int, primary key (ItemID));
Create Table Price(ItemID Int unique references Item(ItemID), FirstBid Float(8,2), BuyPrice Float(8,2), Currently Float(8,2), check (FirstBid <= Currently and (Currently <= BuyPrice or BuyPrice==NULL)) );
Create Table Categories(ItemID Int references Item(ItemID), Category TEXT);
Create Table Bids(ItemID Int references Item(ItemID), BidderID TEXT references User(UserID), ItemTime TEXT, Amount Float(8,2), primary key (ItemID, BidderID, ItemTime), unique (ItemID, ItemTime), unique (ItemID, Amount));
