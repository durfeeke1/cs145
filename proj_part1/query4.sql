Select ItemID From Price Where Currently = (Select Max(Currently) as maximum From Price);

