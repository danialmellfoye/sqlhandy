
----------------------- DATABASE SNAPSHOTS -------------------------

CREATE DATABASE HR;
GO

USE HR;

CREATE TABLE Employees (
  Id int IDENTITY PRIMARY KEY,
  FirstName varchar(50) NOT NULL,
  LastName varchar(50) NOT NULL
);

INSERT INTO Employees (FirstName, LastName)
  VALUES ('John', 'Doe'),
  ('Jane', 'Doe');

  -- CREATING A SNAP SHOT

CREATE DATABASE HR_Snapshots3
ON ( NAME = HR, FILENAME = 'D:\Databases\SNAP_SHOTS\hr3.mdf')  
AS SNAPSHOT OF HR; 

use HR_Snapshots2

Select * from Employees

USE master;

RESTORE DATABASE HR
FROM DATABASE_SNAPSHOT='HR_Snapshots';



create table ss(ss int);


drop database HR;


select * from ss;