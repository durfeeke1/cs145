PRAGMA foreign_keys = ON;

-- Insert into Price
INSERT INTO Item
SELECT 1111111111, "rulabula", "NEW_ITEM", "DESCRIPTION", 1;
--
INSERT INTO Price
('ItemID','FirstBid','BuyPrice','Currently')
SELECT 1111111111, 4.00, 6.00, 4.00;
-- Fix
DELETE FROM Price
Where ItemID=1111111111;
--
DELETE FROM Item
WHERE ItemID = 1111111111;

-- Update to Price
UPDATE Price
SET Currently = 28.00
WHERE ItemID = 1043495702 and  Currently = 28.00;
-- no fix needed

--Insert into Bids
--Insert on Bids violation
INSERT INTO Bids
('ItemID', 'BidderID','Time','Amount')
SELECT 1043495702, "watchdenmark", "2001-12-13 20:40:08", 27.97;
--Fix
DELETE FROM Bids
Where ItemID = 1043495702 and BidderID = "watchdenmark" and Time = "2001-12-13 20:40:08";

--Update to Bids
UPDATE Bids
Set Amount = 25.00
Where ItemID = 1043495702 and Amount = 25.00;
--No Fix

-- Delete From Bids
DELETE From Bids
Where ItemID = 1043495702 and Amount = 25.00;
--Fix
INSERT INTO Bids
('ItemID', 'BidderID','Time','Amount')
SELECT 1043495702, "mrwvh", "2001-12-09 10:00:07", 25.00;
 

drop trigger current_largest;
drop trigger current_largest2;
drop trigger current_largest3;
drop trigger current_largest4;
drop trigger current_largest5; 
