PRAGMA foreign_keys = ON;
-- all user id's are unique
INSERT INTO User
SELECT "THIS_HAS_TO_BE_A_UNIQUE_12345",5,"Rhode Island", "USA";
--
DELETE FROM User
Where UserID = "THIS_HAS_TO_BE_A_UNIQUE_12345";
-- all item Id's are unique
INSERT INTO Item
SELECT "1111111111", "rulabula", "NEW_ITEM", "DESCRIPTION", 1;
--
DELETE FROM Item
WHERE ItemID = 1111111111;
-- (Bid.itemID and Bid.Amount) is unique and 
--(Bid.ItemID, Bid.Time) is  unique and
-- Bid.Item reference a real item and
--Bid.BidderID references a real user ID
INSERT INTO Bids
SELECT "1043374545", "dollface94","2001-03-01 18:10:41", 30.21;
--
DELETE FROM Bids
Where ItemID = "1043374545" and BidderId = "dollface94" and Time = "2001-03-01 18:10:41";
-- Time.Item ID is unique
-- Time.ITem Id references a real user ID
-- Time.Start < Time.End
INSERT INTO Item
SELECT 1111111111, "rulabula", "NEW_ITEM", "DESCRIPTION", 1;
INSERT INTO Time
SELECT 1111111111,"2001-03-01 18:10:41", "2001-04-01 18:10:41";
--
DELETE FROM Time
WHERE ItemID = 1111111111;
DELETE FROM Item
WHERE ItemID = 1111111111;
-- price itemID is unique
-- price itemID references a real item
-- price.firstBid<=price.Current
-- price.Current <= price.BuyPrice
INSERT INTO Item
SELECT 1111111111, "rulabula", "NEW_ITEM", "DESCRIPTION", 1;
INSERT INTO Price
SELECT 1111111111,1.00, 5.00, 2.00;
--
DELETE FROM Price
WHERE ItemID = 1111111111;
DELETE FROM Item
WHERE ItemID = 1111111111;
-- category.itemID reference a real itemID
INSERT INTO Item
SELECT 1111111111, "rulabula", "NEW_ITEM", "DESCRIPTION", 1;
INSERT INTO Categories
SELECT 1111111111,"NUM CHUCKS";
--
DELETE FROM Categories
WHERE ItemID = 1111111111;
DELETE FROM Item
WHERE ItemID = 1111111111;


