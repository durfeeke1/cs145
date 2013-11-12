SELECT * FROM Bids WHERE ItemID = (Select ItemID From Price Where Currently = (Select Max(Currently) as maximum From Price));
Select ItemID From Price Where Currently = (Select Max(Currently) as maximum From Price);
SELECT count(*), "NO BID" FROM Bids Where ItemID = 1046871451;
SELECT * FROM Price Where ItemID = 1046871451;
