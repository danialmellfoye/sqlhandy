use new_database_dani;

EXEC sys.sp_cdc_enable_db  -- It enables CDC

--Database 'new_database_dani' is already enabled for Change Data Capture. Ensure that the correct database context is set, 
--and retry the operation. To report on the databases enabled for Change Data Capture, query the is_cdc_enabled column 
--in the sys.databases catalog view.

SELECT name, is_cdc_enabled
FROM sys.databases WHERE database_id = DB_ID();

select is_cdc_enabled,* from sys.databases;

create table CDCsample(Name varchar(10))

EXEC sys.sp_cdc_enable_table 
@source_schema = N'dbo',  
@source_name   = N'CDCsample',  
@role_name     = Null,    
@supports_net_changes = 1 --Only execute if you set primary key else execute below query

EXEC sys.sp_cdc_enable_table 
@source_schema = N'dbo',  
@source_name   = N'CDCsample',  
@role_name     = Null,    
@supports_net_changes = 0

insert into CDCsample values ('DANIAL');
insert into CDCsample values ('HARISH');
INSERT INTO CDCsample VALUES ('RAJ');

SELECT * FROM CDCsample;

SELECT * FROM [cdc].[dbo_CDCsample_CT] 