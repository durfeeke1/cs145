drop table if exists CurrTime;
create table CurrTime(curr_time);
insert into CurrTime values ("2001-12-20 00:00:01");
select curr_time from CurrTime;
