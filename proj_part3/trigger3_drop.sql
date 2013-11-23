PRAGMA foreign_keys = ON;

--Update Time
UPDATE Time
Set curr_time = "2001-12-20 00:00:01";

drop trigger time_forward;
drop trigger time_forward2;
