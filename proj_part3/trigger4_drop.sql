PRAGMA foreign_keys = ON;

--Insert into Bids
--Insert on Bids violation
INSERT INTO Bids
('ItemID', 'BidderID','ItemTime','Amount')
SELECT 1043495702, "watchdenmark", "2001-12-13 20:40:08", 27.97;
--Fix
DELETE FROM Bids
Where ItemID = 1043495702 and BidderID = "watchdenmark" and ItemTime = "2001-12-13 20:40:08";

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
('ItemID', 'BidderID','ItemTime','Amount')
SELECT 1043495702, "mrwvh", "2001-12-09 10:00:07", 25.00;
 

drop trigger num_of_bids;
drop trigger num_of_bids2;
drop trigger num_of_bids3;
