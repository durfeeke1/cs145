PRAGMA foreign_keys = ON;

--Insert Into Bids
INSERT INTO Bids
('ItemID', 'BidderID','ItemTime','Amount')
SELECT 1043495702, "watchdenmark", "2001-12-13 20:40:06", 27.97;
--Fix
DELETE FROM Bids
Where ItemID = 1043495702 and BidderID = "watchdenmark" and ItemTime = "2001-12-13 20:40:06";

-- Update to Bids
UPDATE Bids
Set ItemTime = "2001-12-13 20:40:07"
Where ItemID = 1043495702  and ItemTime = "2001-12-10 20:40:07"; 
--no fix needed

--Insert Into ItemTime
INSERT INTO Item
SELECT 1111111111, "rulabula", "NEW_ITEM", "DESCRIPTION", 1;
--
INSERT INTO ItemTime
('ItemID','Started','Ends')
SELECT 1111111111, "2001-12-10 20:40:07",  "2001-12-10 20:40:08";
-- Fix
DELETE FROM ItemTime 
Where ItemID=1111111111;
--
DELETE FROM Item
WHERE ItemID = 1111111111;

--Update ItemTime
UPDATE ItemTime
Set Started = "2001-12-03 20:40:06"
Where ItemID = 1043495702;
--Fix
UPDATE ItemTime
Set Started = "2001-12-03 20:40:07"
Where ItemID = 1043495702;

drop trigger correct_bid_time;
drop trigger correct_bid_time2;
drop trigger correct_bid_time3;
drop trigger correct_bid_time4;

