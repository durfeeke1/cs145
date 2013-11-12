S145 Project Part 1
10/17/2013

Part B -- Design your relational schema
Now that you understand the data you'll be working with, design a good relational schema for it.

1.	List your relations. Please specify all keys that hold on each relation. You need not specify attribute types at this stage.
	
        User(User ID, Rating, Location, Country)
	Categories (Item ID, Category) 
        Price(Item ID, First Bid, Buy Price, Currently)
	Time(Item ID, Started, Ends)
	Item(Item ID, User ID (Seller), Name, Description, Number of Bids)
	BID(Item ID,  User ID(Buyer), Time, Amount)

	List all completely nontrivial functional dependencies that hold on each relation, excluding those that effectively specify keys. Don't worry if your answer turns out to be "none".
None

2.	Are all of your relations in Boyce-Codd Normal Form (BCNF)? If not, either redesign them and start over, or explain why you feel it is advantageous to use non-BCNF relations.
Yes

3.	List all nontrivial multivalued dependencies that hold on each relation, excluding those that are also functional dependencies. Again, don't worry if your answer turns out to be "none". (It's quite common to have "none" for this part; more so than for part 2.)
None

4.	Are all of your relations in Fourth Normal Form (4NF)? If not, either redesign them and start over, or explain why you feel it is advantageous to use non-4NF relations.
Yes

