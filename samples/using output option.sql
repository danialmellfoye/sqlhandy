use new_database_dani;

/*

What does output do in SQL Server?
	SQL Server OUTPUT clause returns the values of each row that was affected by an INSERT, UPDATE or DELETE statements. 
The Output clause returns a copy of the data that can be inserted into a separate table during the execution of the query


*/

create table outputtable(name varchar(50));

insert into outputtable(name)
output inserted.name as ins
values ('Danial');

update outputtable set name = 'Bala' 
output deleted.name as oldname, inserted.name as updated_to 
where name = 'Danial';

delete outputtable 
output deleted.name as del 
where name = 'Bala';

truncate table outputtable;

create table outputhistory(history varchar(100), date_and_tiem datetime );

insert into outputtable(name)
output 'Inserted value is '+inserted.name , getdate()
into outputhistory
values ('Danial');

update outputtable set name = 'Bala' 
output deleted.name+' changed as '+inserted.name , getdate()
into outputhistory
where name = 'Danial';

delete outputtable 
output deleted.name+' deleted', getdate()
into outputhistory
where name = 'Bala';
 
select * from outputhistory;
truncate table outputhistory;

select * from outputtable;

go
create proc sp_outputexample(@act varchar(20), @name varchar(50), @ud varchar(50))
as
begin
	if @act = 'ins'
	insert into outputtable(name)
	output 'Inserted value is '+inserted.name , getdate()
	into outputhistory
	values (@name);
	
	if @act = 'upt'
	update outputtable set name = @name 
	output deleted.name+' changed as '+inserted.name , getdate()
	into outputhistory
	where name = @ud;
	
	if @act = 'del'
	delete outputtable 
	output deleted.name+' deleted', getdate()
	into outputhistory
	where name = @name;

	if @act <> 'ins' and @act <> 'upt' and @act <> 'del'
	print 'Incorrect action';
end;

exec sp_outputexample 'upt', 'Murugesh','Mukesh';

