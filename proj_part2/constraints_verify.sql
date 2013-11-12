-- --------------------- K -------------------------
-- make sure all user ids are unique
SELECT * FROM 
(SELECT count(*) as c1 FROM User
GROUP BY UserID)
WHERE c1 > 1;
-- make sure all item ids are unique
SELECT * FROM
(SELECT count(*) as c1 FROM Item
GROUP BY ItemID)
WHERE c1 > 1;
-- make sure no two bids from the same user on the same item happen at the same time
SELECT * FROM
(SELECT count(*) as c1 FROM Bids as I1,Bids as I2 WHERE I1.ItemID =I2.ItemID and I1.BidderID = I2.BidderID and I1.Time = I2.Time and I1.Amount <> I2.Amount)
WHERE c1 > 0;
--make sure no two bids on the same item happen at the same time
SELECT * FROM
(SELECT count(*) as c1 FROM Bids as I1,Bids as I2 WHERE I1.ItemID =I2.ItemID and I1.Time = I2.Time and (I1.Amount <> I2.Amount or I1.BidderID <> I2.BidderID) )
WHERE c1 > 0;
--make sure no two bids on the same item are for the same amount
SELECT * FROM
(SELECT count(*) as c1 FROM Bids as I1,Bids as I2 WHERE I1.ItemID =I2.ItemID and I1.Amount = I2.Amount and (I1.Time <> I2.Time or I1.BidderID <> I2.BidderID) )
WHERE c1 > 0;
-- mkae sure that all Time.ID's are unique
SELECT * FROM
(SELECT count(*) as c1 FROM Time
GROUP BY ItemID)
WHERE c1 > 1;
-- make sure all Price.ItemID's are unique
SELECT * FROM
(SELECT count(*) as c1 FROM Price
GROUP BY ItemID)
WHERE c1 > 1;
-- ------------------ C -------------------
-- make sure the first bid is less than or equal to the current price
SELECT * FROM
(SELECT count(*) as c1 FROM Price
WHERE FirstBid > Currently )
WHERE c1 > 0;
-- make sure the current price is less than the buy price
SELECT * FROM
(SELECT count(*) as c1 FROM Price
WHERE Currently > BuyPrice)
WHERE c1 > 0;
-- make sure the start time is less than the end time
SELECT * FROM
(SELECT count(*) as c1 FROM Time
WHERE datetime(Started) > datetime(Ends))
WHERE c1 > 0;
-- ---------------- R -----------------------------
--make sure Item.userID refereces User.userID
SELECT * FROM Item WHERE NOT EXISTS ( SELECT * FROM User WHERE Item.UserID = User.UserID);
--make sure Bid.userID references User.userID
SELECT * FROM Bids WHERE NOT EXISTS ( SELECT * FROM User WHERE Bids.BidderID = User.UserID);
--make sure Bid.itemID references Item.ItemID
SELECT * FROM Bids WHERE NOT EXISTS ( SELECT * FROM Item WHERE Bids.ItemID = Item.ItemID);
--make sure Time.itemID references Item.ItemID
SELECT * FROM Time WHERE NOT EXISTS ( SELECT * FROM Item WHERE Time.ItemID = Item.ItemID);
--make sure Price.itemID references Item.ItemID
SELECT * FROM Price WHERE NOT EXISTS ( SELECT * FROM Item WHERE Price.ItemID = Item.ItemID);
--make sure Category.itemID references Category.ItemID
SELECT * FROM Categories WHERE NOT EXISTS ( SELECT * FROM Item WHERE Categories.ItemID = Item.ItemID);

