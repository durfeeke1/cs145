-- description: These triggers make sure that the Bid ItemTime is after the Start ItemTime and before the End ItemTime of the auction
PRAGMA foreign_keys = ON;
--insert on bids
drop trigger if exists correct_bid_time;
CREATE TRIGGER  correct_bid_time
BEFORE INSERT ON Bids
FOR EACH ROW
-- raise error if the new bid does not start after the start time or before the end time 
BEGIN
   SELECT RAISE(rollback, 'Error Inserting Into Bids')
   WHERE  EXISTS (
   SELECT * FROM ItemTime WHERE ItemTime.ItemID = New.ItemID and (datetime(New.ItemTime) < datetime(ItemTime.Started) or datetime(New.ItemTime)>datetime(ItemTime.Ends)));
END;

--update on bids
drop trigger if exists correct_bid_time2;
CREATE TRIGGER correct_bid_time2
BEFORE UPDATE ON Bids
FOR EACH ROW
-- raise error if the updated bid does not start after the start time or before the end time
BEGIN
   SELECT RAISE(rollback, 'Error Updating Bids')
   WHERE  EXISTS (
   SELECT * FROM ItemTime WHERE ItemTime.ItemID = New.ItemID and (datetime(New.ItemTime) < datetime(ItemTime.Started) or datetime(New.ItemTime)>datetime(ItemTime.Ends)));
END;

-- insert on time
drop trigger if exists correct_bid_time3;
CREATE TRIGGER  correct_bid_time3
BEFORE INSERT ON ItemTime
FOR EACH ROW
-- raise error if the new time has a bid that begins before its start time or after its end time
BEGIN
   SELECT RAISE(rollback, 'Error Inserting Into ItemTime')
   WHERE  EXISTS (
   SELECT * FROM Bids WHERE Bids.ItemID = New.ItemID and (datetime(Bids.ItemTime) < datetime(New.Started) or datetime(Bids.ItemTime)>datetime(New.Ends)));
END;
;

--update on time
drop trigger if exists correct_bid_time4;
CREATE TRIGGER correct_bid_time4
BEFORE UPDATE ON ItemTime
FOR EACH ROW
-- raise error if the new time has a bid that begins before its start time or after its end time
BEGIN
   SELECT RAISE(rollback, 'Error Updating ItemTime')
   WHERE  EXISTS (
   SELECT * FROM Bids WHERE Bids.ItemID = New.ItemID and (datetime(Bids.ItemTime) < datetime(New.Started) or datetime(Bids.ItemTime)>datetime(New.Ends)));
END;


--delete from bids constraint still holds
--delete from time constraint still holds



--Insert on Bids violation
INSERT INTO Bids
('ItemID', 'BidderID','ItemTime','Amount')
SELECT 1043495702, "watchdenmark", "2013-12-13 20:40:08", 30.00;
-- No Fix Needed

-- Update to Bids Violation
UPDATE  Bids
SET ItemTime  = "2013-12-10 12:40:07"
WHERE ItemID = 1043495702  and  Amount = 28.00;
-- No Fix Needed

--Insert into ItemTime
INSERT INTO ItemTime
('ItemID','Started','Ends')
SELECT 1043495702, "2013-12-13 20:40:08", "2014-12-13 20:40:08";
--no Fix Needed

--Update ItemTime
Update ItemTime
SET Ends  = "2000-12-13 20:40:08"
WHERE ItemID = 1043495702;
