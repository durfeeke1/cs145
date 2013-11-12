-- description: These triggers make sure that the Bid Time is after the Start Time and before the End Time of the auction
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
   SELECT * FROM Time WHERE Time.ItemID = New.ItemID and (datetime(New.Time) < datetime(Time.Started) or datetime(New.Time)>datetime(Time.Ends)));
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
   SELECT * FROM Time WHERE Time.ItemID = New.ItemID and (datetime(New.Time) < datetime(Time.Started) or datetime(New.Time)>datetime(Time.Ends)));
END;

-- insert on time
drop trigger if exists correct_bid_time3;
CREATE TRIGGER  correct_bid_time3
BEFORE INSERT ON Time
FOR EACH ROW
-- raise error if the new time has a bid that begins before its start time or after its end time
BEGIN
   SELECT RAISE(rollback, 'Error Inserting Into Time')
   WHERE  EXISTS (
   SELECT * FROM Bids WHERE Bids.ItemID = New.ItemID and (datetime(Bids.Time) < datetime(New.Started) or datetime(Bids.Time)>datetime(New.Ends)));
END;
;

--update on time
drop trigger if exists correct_bid_time4;
CREATE TRIGGER correct_bid_time4
BEFORE UPDATE ON Time
FOR EACH ROW
-- raise error if the new time has a bid that begins before its start time or after its end time
BEGIN
   SELECT RAISE(rollback, 'Error Updating Time')
   WHERE  EXISTS (
   SELECT * FROM Bids WHERE Bids.ItemID = New.ItemID and (datetime(Bids.Time) < datetime(New.Started) or datetime(Bids.Time)>datetime(New.Ends)));
END;


--delete from bids constraint still holds
--delete from time constraint still holds



--Insert on Bids violation
INSERT INTO Bids
('ItemID', 'BidderID','Time','Amount')
SELECT 1043495702, "watchdenmark", "2013-12-13 20:40:08", 30.00;
-- No Fix Needed

-- Update to Bids Violation
UPDATE  Bids
SET Time  = "2013-12-10 12:40:07"
WHERE ItemID = 1043495702  and  Amount = 28.00;
-- No Fix Needed

--Insert into Time
INSERT INTO Time
('ItemID','Started','Ends')
SELECT 1043495702, "2013-12-13 20:40:08", "2014-12-13 20:40:08";
--no Fix Needed

--Update Time
Update Time
SET Ends  = "2000-12-13 20:40:08"
WHERE ItemID = 1043495702;
