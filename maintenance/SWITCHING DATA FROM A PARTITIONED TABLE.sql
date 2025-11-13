
/*---------------                                                                ------------------
--------------------                                                                 -----------------
SITE TO REFER : https://blog.pragmaticworks.com/table-partitioning-in-sql-server-partition-switching
--------------------                                                                 -----------------
*/---------------								                                  -----------------

									--==[Syntaxes]==--
/*
	1. SWITCH FROM NON-PARTITIONED TO NON-PARTITIONED
--	ALTER TABLE <SourceTableName> SWITCH TO <TargetTableName>;

	2. SWITCH FROM NON-PARTITIONED TO PARTITION
--	ALTER TABLE <SourceTableName> SWITCH TO <TargetTableName> PARTITION <n>;

	3. SWITCH FROM PARTITION TO NON-PARTITIONED
--	ALTER TABLE <SourceTableName> SWITCH PARTITION <n> TO <TargetTableName>;

	4. SWITCH FROM PARTITION TO PARTITION
--	ALTER TABLE <SourceTableName> SWITCH PARTITION <n> TO <TargetTableName> PARTITION <n>;
*/


--Swaping or switching data to another empty table using switch to syntax
--below syntax used only for non partitoned tables
create table sample1 (id int, name varchar(20));

SELECT count(*) FROM  sample1
SELECT count(*) FROM  sample2

ALTER TABLE sample1 SWITCH TO sample2

--below syntax used to move data from partioned table to newly created non partitioned table which is empty
--It is used to archive old data is seperate table when the data is not used frequently

SELECT COUNT(*) FROM SalesRight
SELECT COUNT(*) FROM SalesRight_2

SELECT * FROM sys.partitions WHERE OBJECT_NAME(object_id) = 'SalesRight'

ALTER TABLE SalesRight SWITCH PARTITION 1 TO SalesRight_2; --It moves the 1st partition to the newly created table
