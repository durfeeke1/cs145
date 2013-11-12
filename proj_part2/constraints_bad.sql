PRAGMA foreign_keys = ON;
-- all user id's are unique
INSERT INTO User
SELECT "rulabula",5,"Rhode Island", "USA";
-- all item Id's are unique
INSERT INTO Item
SELECT "1043374545", "rulabula", "NEW_ITEM", "DESCRIPTION", 1;
--al item usr  ID's reference real Id's
INSERT INTO Item
SELECT "1043374545", "NOT_A_REAL_USER_12345", "NEW_ITEM", "DESCRIPTION", 1;
--(Bid.ItemID, Bid.ItemTime) is  unique and
INSERT INTO Bids
SELECT "1043495702", "dollface94","2001-12-04 23:20:08", 13.00;
-- (Bid.itemID and Bid.Amount) is unique and 
INSERT INTO Bids
SELECT "1043495702", "dollface94","2001-12-04 23:20:07", 12.99;
-- Bid.Item reference a real item and
INSERT INTO Bids
SELECT 1111111111, "dollface94","2001-12-04 23:20:07", 12.99;
--Bid.BidderID references a real user ID
INSERT INTO Bids
SELECT 1043495702, "dollface94_NOT_REAL","2001-12-04 23:20:07", 12.99;
-- ItemTime.Item ID is unique
INSERT INTO Item
SELECT 1043495702, "rulabula", "ITEM_DUP", "DESCRIPTION", 1;
-- ItemTime.ITem Id references a real user ID
INSERT INTO ItemTime
SELECT 1111111111,"2001-03-01 18:10:41", "2001-04-01 18:10:41";
-- ItemTime.Start < ItemTime.End
INSERT INTO Item
SELECT 1111111111, "rulabula", "NEW_ITEM", "DESCRIPTION", 1;
INSERT INTO ItemTime
SELECT 1111111111,"2001-03-01 18:10:41", "2001-03-01 18:10:41";
--
DELETE FROM Item
WHERE ItemID = 1111111111;
-- price itemID references a real item
INSERT INTO Price
SELECT 1111111111,1.00, 5.00, 2.00;
-- price itemID is unique
INSERT INTO Price
SELECT 043495702,1.00, 5.00, 2.00;
-- price.firstBid<=price.Current
INSERT INTO Item
SELECT 1111111111, "rulabula", "NEW_ITEM", "DESCRIPTION", 1;
INSERT INTO Price
SELECT 1111111111,3.00, 5.00, 2.00;
--
DELETE FROM Price
WHERE ItemID = 1111111111;
DELETE FROM Item
WHERE ItemID = 1111111111;
-- price.Current <= price.BuyPrice
INSERT INTO Item
SELECT 1111111111, "rulabula", "NEW_ITEM", "DESCRIPTION", 1;
INSERT INTO Price
SELECT 1111111111,1.00, 5.00, 6.00;
--
DELETE FROM Price
WHERE ItemID = 1111111111;
DELETE FROM Item
WHERE ItemID = 1111111111;
-- category.itemID reference a real itemID
INSERT INTO Categories
SELECT 1111111111,"NUM CHUCKS";
