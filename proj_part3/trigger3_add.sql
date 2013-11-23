-- description: These triggers make sure that time only moves forward 
PRAGMA foreign_keys = ON;
--insert on bids
drop trigger if exists time_forward;
CREATE TRIGGER  time_forward
BEFORE INSERT ON Time
FOR EACH ROW
-- raise error if there is more than one row in Time
BEGIN
   SELECT RAISE(rollback, 'Error Inserting Into Time')
   WHERE EXISTS (SELECT * FROM Time); 
END;

--update on bids
drop trigger if exists time_forward2;
CREATE TRIGGER time_forward2
BEFORE UPDATE ON Time
FOR EACH ROW
-- raise error if the new time is less than the old time 
WHEN datetime(New.curr_time) < datetime(Old.curr_time)
BEGIN
   SELECT RAISE(rollback, 'Error Updating Time');
END;

--Insert on Time violation
INSERT INTO Time
('curr_time')
SELECT "2013-12-13 20:40:08";
-- No Fix Needed

--Update Time
Update Time
SET curr_time  = "1600-12-13 20:40:08";
-- No Fix Needed
