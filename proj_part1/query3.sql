Select Count(*) From (Select Count(Category) as cat_count From Categories Group By ItemID Having cat_count = 4);

