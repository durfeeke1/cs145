-- decsription: These triggers insures that the current price is the largest bid or if there are no bids it is equal to the FirstBid.
PRAGMA foreign_keys = ON;
drop trigger if exists current_largest;
CREATE TRIGGER current_largest
AFTER INSERT ON Bids
FOR EACH ROW
-- set the Current price to the Amount of the new bid if it is bigger than all existing bids on that item
BEGIN
   UPDATE Price
   SET Currently = New.Amount
   WHERE( Price.ItemID = New.ItemID and NOT EXISTS (
   SELECT * FROM Bids WHERE Bids.ItemId = New.ItemID and Bids.Amount>New.Amount) 
   );
END;
-- violation
INSERT INTO Bids
('ItemID', 'BidderID','ItemTime','Amount')
SELECT 1043495702, "watchdenmark", "2001-12-13 20:40:08", 30.00;
--verification
SELECT * FROM Price
Where ItemID = 1043495702 and Currently = 30.00;
--Fix 
DELETE FROM Bids
Where ItemID = 1043495702 and BidderID = "watchdenmark" and ItemTime = "2001-12-13 20:40:08";
--Fix
UPDATE PRICE
SET Currently = 28.00
WHERE ItemID = 1043495702;

--Delete from Bids
drop trigger if exists current_largest2;
CREATE TRIGGER current_largest2
AFTER DELETE ON Bids
FOR EACH ROW
-- Set Current to the FirstBid if there are no bids on that item
-- Otherwise, set Current to the amount of the largest bid on that item
BEGIN
   UPDATE Price
   SET Currently = FirstBid 
   WHERE (SELECT count(*) FROM Bids as B3 WHERE Price.ItemID = B3.ItemID)=0; 
   UPDATE Price
   SET Currently = (SELECT Amount FROM Bids
                    WHERE( Price.ItemID = ItemID and NOT EXISTS (
                    SELECT * FROM Bids as B2 WHERE Price.ItemId = B2.ItemID and 
                                                   B2.Amount>Bids.Amount)))
   WHERE (SELECT count(*) FROM Bids as B3 WHERE Price.ItemID = B3.ItemID)>0;
END;
-- violation
DELETE FROM Bids
WHERE ItemID = 1043495702 and BidderID= "allyw1" and  Amount = 28.00;
--verification
SELECT *, "Delete" FROM Price
Where ItemID = 1043495702 and Currently = 25.00;
-- Fix
INSERT INTO Bids
('ItemID', 'BidderID','ItemTime','Amount')
SELECT 1043495702, "allyw1", "2001-12-10 20:40:07", 28.00;

--Update to Bids
drop trigger if exists current_largest3;
CREATE TRIGGER current_largest3
AFTER UPDATE ON Bids
FOR EACH ROW
--set current to the largest bid on that item
BEGIN
   UPDATE Price
   SET Currently = (SELECT Amount FROM Bids
                   WHERE( 
                      Price.ItemID = ItemID and NOT EXISTS (
                      SELECT * FROM Bids as B2 WHERE Price.ItemID = B2.ItemID and 
                                                     B2.Amount>Bids.Amount)))
   WHERE (SELECT count(*) FROM Bids as B3 WHERE Price.ItemID = B3.ItemID)>0; 
END;
-- violation
UPDATE  Bids
SET Amount = 22.01
WHERE ItemID = 1043495702  and  Amount = 28.00;
--verification
SELECT * FROM Price
Where ItemID = 1043495702 and Currently = 25.00;
-- Fix
UPDATE Price
SET Currently = 28.00
WHERE ItemID = 1043495702  and  Currently = 22.01;
-- Fix
UPDATE  Bids
SET Amount = 28.00
WHERE ItemID = 1043495702  and  Amount = 22.01;


--Update to Price
drop trigger if exists current_largest4;
CREATE TRIGGER current_largest4
BEFORE UPDATE ON Price
FOR EACH ROW
BEGIN
   -- raise error if there is a bid on the item that is bigger than the new Current price
   -- or if there is no bid equal to the current amount and the bid is not equal to first bid
   SELECT RAISE(ignore)
   WHERE EXISTS (
   SELECT * FROM Bids WHERE Bids.ItemId = New.ItemID and Bids.Amount>New.Currently) or (NOT EXISTS (SELECT * FROM Bids WHERE Bids.ItemId = New.ItemID and Bids.Amount=New.Currently) and New.Currently<>New.FirstBid);
END;
-- violation
UPDATE Price
SET Currently = 0.00
WHERE ItemID = 1043495702 and  Currently = 28.00;
--verification
SELECT * FROM Price
Where ItemID = 1043495702 and Currently = 28.00;
-- No Fix. It is ignored

--Insert to Price
drop trigger if exists current_largest5;
CREATE TRIGGER current_largest5
BEFORE INSERT ON Price
FOR EACH ROW
BEGIN
   -- raise error if there is a bid on the item that is bigger than the new Current price
   -- or if there is no bid equal to the current amount and the bid is not equal to first bid
   SELECT RAISE(ignore)
   WHERE EXISTS (
   SELECT * FROM Bids WHERE Bids.ItemId = New.ItemID and Bids.Amount>New.Currently) or (NOT EXISTS (SELECT * FROM Bids WHERE Bids.ItemId = New.ItemID and Bids.Amount=New.Currently) and New.Currently<>New.FirstBid);
END;
-- violation
INSERT INTO Price
('ItemID','FirstBid','BuyPrice','Currently')
SELECT 1111111111, 4.00, 6.00, 5.00;
--verification
SELECT count(*),"Insert into Price" FROM Price
Where ItemID = 1111111111;


-- If price is deleted constraint still holds


--Check Constraint Holds
SELECT * FROM Price WHERE(EXISTS
(SELECT * FROM Bids WHERE Bids.ItemID = Price.ItemID and Bids.Amount > Price.Currently) and  NOT EXISTS(SELECT * FROM Bids WHERE Bids.ItemID = Price.ItemID and Bids.Amount = Price.Currently));
