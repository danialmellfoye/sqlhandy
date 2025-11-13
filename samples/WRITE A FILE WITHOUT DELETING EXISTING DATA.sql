
--sp_configure 'show advanced options', 1 
--GO 
--RECONFIGURE; 
--GO 
--sp_configure 'Ole Automation Procedures', 1 
--GO 
--RECONFIGURE; 
--GO 
--sp_configure 'show advanced options', 1 
--GO 
--RECONFIGURE;

CREATE PROC WriteToFile
@File VARCHAR(MAX),
@Text VARCHAR(MAX)
AS
BEGIN
DECLARE @OLE INT
DECLARE @FileID INT
EXEC sp_OACreate 'Scripting.FileSystemObject', @OLE OUT
EXEC sp_OAMethod @OLE, 'OpenTextFile', @FileID OUT, @File, 8, 1
EXEC sp_OAMethod @FileID, 'WriteLine', NULL, @Text
EXEC sp_OADestroy @FileID
EXEC sp_OADestroy @OLE
END

exec dbo.WriteToFile 'D:\HI.sql','use master'
exec dbo.WriteToFile 'D:\HI.sql','select * '
exec dbo.WriteToFile 'D:\HI.sql','from college'
--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X



/****   save result as excel   ****/
DECLARE @cmd varchar(1000)
SET @cmd = 'bcp "SELECT * FROM dbo.College" queryout "D:\HI2.xls" -c -t\t -T -S NDSL039 -d new_database_dani'
--print(@cmd)
EXEC master.dbo.xp_cmdshell @cmd

/*   OR   */

DECLARE @table TABLE
( 
text varchar(max)
)
insert into @table
SELECT convert(varchar,regno)+char(9)+department+char(13) FROM College
declare @text varchar(max)
SELECT @text = REPLACE(REPLACE(REPLACE((SELECT * FROM @table
FOR XML PATH('')),'/',''),'<text>',''),'&#x0D;',char(13))

DECLARE @OLE INT
DECLARE @FileID INT
EXEC sp_OACreate 'Scripting.FileSystemObject', @OLE OUT
EXEC sp_OAMethod @OLE, 'OpenTextFile', @FileID OUT, 'D:\HI2.xls', 8, 1
EXEC sp_OAMethod @FileID, 'WriteLine', NULL, @text
EXEC sp_OADestroy @FileID
EXEC sp_OADestroy @OLE
--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X--X