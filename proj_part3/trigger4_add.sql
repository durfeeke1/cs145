-- decsription: These triggers insures that the number of bids corresponds to the actual number of bids
PRAGMA foreign_keys = ON;
drop trigger if exists num_of_bids;
CREATE TRIGGER num_of_bids
AFTER INSERT ON Bids
FOR EACH ROW
BEGIN
   UPDATE Item
   SET NumberOfBids = (
   SELECT count(*) FROM Bids
   WHERE Bids.ItemID = New.ItemID)
   WHERE Item.ItemID = New.ItemID;
END;

--Delete from Bids
drop trigger if exists num_of_bids2;
CREATE TRIGGER num_of_bids2
AFTER DELETE ON Bids
FOR EACH ROW
BEGIN
   UPDATE Item
   SET NumberOfBids = (
   SELECT count(*) FROM Bids
   WHERE Bids.ItemID = Old.ItemID)
   WHERE Item.ItemID = Old.ItemID;
END;
--Update to Bids
drop trigger if exists num_of_bids3;
CREATE TRIGGER num_of_bids3
BEFORE UPDATE ON Bids
FOR EACH ROW
BEGIN
SELECT RAISE(rollback, "Error: Cannot Update Bid");
END;

SELECT NumberOfBids 
FROM Item
WHERE Item.ItemID = 1043495702;

--Insert on Bids violation
INSERT INTO Bids
('ItemID', 'BidderID','ItemTime','Amount')
SELECT 1043495702, "watchdenmark", "2001-12-12 00:00:00", 30.00;
--verification
SELECT NumberOfBids 
FROM Item
WHERE Item.ItemID = 1043495702;
--Update on Bids violation
UPDATE Bids
SET ItemID = 1043374545
WHERE ItemID = 1043495702;
--verification
SELECT NumberOfBids 
FROM Item
WHERE Item.ItemID = 1043495702;
--Fix
DELETE FROM Bids
Where ItemID = 1043495702 and BidderID = "watchdenmark" and ItemTime = "2001-12-12 00:00:00";
--verification
SELECT NumberOfBids 
FROM Item
WHERE Item.ItemID = 1043495702;

--Check Constraint Holds
SELECT ItemID FROM Item WHERE
((SELECT count(*) FROM Bids WHERE Bids.ItemID = Item.ItemID) <> Item.NumberOfBids );
