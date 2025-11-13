

CREATE DATABASE Sales
ON
( NAME = Sales_dat,
    FILENAME = 'D:\Databases\saledat.mdf',
    SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5 )
LOG ON
( NAME = Sales_log,
    FILENAME = 'D:\Databases\salelog.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB ) ;

	use Sales;


create table new_table (field_1 int, field_2 varchar(50));

use master;
drop DATABASE Archive
ON
PRIMARY
    (NAME = Arch1,
    FILENAME = 'D:\Databases\DB_partition\archdat1.mdf',
    SIZE = 100MB,
    MAXSIZE = 200,
    FILEGROWTH = 20),
    ( NAME = Arch2,
    FILENAME = 'D:\Databases\DB_partition\archdat2.ndf',
    SIZE = 100MB,
    MAXSIZE = 200,
    FILEGROWTH = 20),
    ( NAME = Arch3,
    FILENAME = 'D:\Databases\DB_partition\archdat3.ndf',
    SIZE = 100MB,
    MAXSIZE = 200,
    FILEGROWTH = 20)
LOG ON
  (NAME = Archlog1,
    FILENAME = 'D:\Databases\DB_partition\archlog1.ldf',
    SIZE = 100MB,
    MAXSIZE = 200,
    FILEGROWTH = 20),
  (NAME = Archlog2,
    FILENAME = 'D:\Databases\DB_partition\archlog2.ldf',
    SIZE = 100MB,
    MAXSIZE = 200,
    FILEGROWTH = 20) ;
GO

select file_id, name,physical_name,* from sys.database_files


DBCC SHRINKFILE('Arch1',EMPTYFILE);
Select * from SalesOrderHeader

DBCC showfilestats
--ALTER DATABASE Archive REMOVE FILE Arch3

SELECT
[TYPE] = A.TYPE_DESC
,[FILE_Name] = A.name
,[FILEGROUP_NAME] = fg.name
,[File_Location] = A.PHYSICAL_NAME
,[FILESIZE_MB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0)
,[USEDSPACE_MB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0 - ((SIZE/128.0) - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0))
,[USEDSPACE_%] = CAST((CAST(FILEPROPERTY(A.name, 'SpaceUsed')/128.0 AS DECIMAL(10,2))/CAST(A.size/128.0 AS DECIMAL(10,2)))*100 AS DECIMAL(10,2))
,[FREESPACE_MB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0 - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0)
,[FREESPACE_%] = CONVERT(DECIMAL(10,2),((A.SIZE/128.0 - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0)/(A.SIZE/128.0))*100)
,[AutoGrow] = 'By ' + CASE is_percent_growth WHEN 0 THEN CAST(growth/128 AS VARCHAR(10)) + ' MB -'
WHEN 1 THEN CAST(growth AS VARCHAR(10)) + '% -' ELSE '' END
+ CASE max_size WHEN 0 THEN 'DISABLED' WHEN -1 THEN ' Unrestricted'
ELSE ' Restricted to ' + CAST(max_size/(128*1024) AS VARCHAR(10)) + ' GB' END
+ CASE is_percent_growth WHEN 1 THEN ' [autogrowth by percent, BAD setting!]' ELSE '' END
FROM sys.database_files A LEFT JOIN sys.filegroups fg ON A.data_space_id = fg.data_space_id
order by A.TYPE desc, A.NAME;


