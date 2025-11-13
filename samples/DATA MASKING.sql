CREATE DATABASE Masks

USE Masks

--  Default method
 
DROP TABLE IF EXISTS DefaultMask;
        
CREATE TABLE DefaultMask
(
ID		       INT              IDENTITY (1,1) PRIMARY KEY NOT NULL
,Name VARCHAR(255)	MASKED WITH (FUNCTION = 'default()') NULL
,BirthDate     DATE		MASKED WITH (FUNCTION = 'default()') NOT NULL
,Social_Security  BIGINT		MASKED WITH (FUNCTION = 'default()') NOT NULL
,Salary  MONEY		MASKED WITH (FUNCTION = 'default()') NOT NULL
);
GO

INSERT INTO DefaultMask
(
Name, BirthDate, Social_Security, Salary
)
VALUES 
('James Jones',  '1998-06-01', 784562145987,100),
( 'Pat Rice',  '1982-08-12', 478925416938,200),
('George Eliot',  '1990-05-07', 794613976431,300);

SELECT * FROM DefaultMask

DROP USER IF EXISTS DefaultMaskTestUser;
CREATE USER DefaultMaskTestUser WITHOUT LOGIN;
 
GRANT SELECT ON DefaultMask TO DefaultMaskTestUser;
 
EXECUTE AS USER = 'DefaultMaskTestUser';
SELECT * FROM DefaultMask;
 
REVERT;

--  Partial method

USE Masks
 
DROP TABLE IF EXISTS PartialMask;
        
CREATE TABLE PartialMask
(
ID		       INT              IDENTITY (1,1) PRIMARY KEY NOT NULL
,Name VARCHAR(255)	MASKED WITH (FUNCTION = 'partial(2, "XXXX",2)') NULL
,Comment   NVARCHAR(255)		MASKED WITH (FUNCTION = 'partial(5, "XXXX", 5)') NOT NULL
);
GO

INSERT INTO PartialMask
(
  Name,  Comment
)
VALUES 
('James Jones',  'The tea was fantastic'),
( 'Pat Rice',  'I like these mangoes' ),
('George Eliot',  'I do not really like this');

SELECT * FROM PartialMask

DROP USER IF EXISTS PartialMaskTestUser;
CREATE USER  PartialMaskTestUser WITHOUT LOGIN;
        
GRANT SELECT ON PartialMask TO PartialMaskTestUser;  
        
EXECUTE AS USER = 'PartialMaskTestUser';  
SELECT * FROM PartialMask

REVERT;

--  Email Masking

USE Masks
 
DROP TABLE IF EXISTS EmailMask;
        
CREATE TABLE EmailMask
(
  ID	   INT IDENTITY (1,1) PRIMARY KEY NOT NULL
 ,Email VARCHAR(255)	MASKED WITH (FUNCTION =  'email()') NULL
         
);
GO

INSERT INTO EmailMask
(
 Email
)
VALUES 
('nickijames@yahoo.com'),
( 'loremipsum@gmail.com' ),
('geowani@hotmail.com');

SELECT * FROM EmailMask;

DROP USER IF EXISTS EmailMaskTestUser;
CREATE USER EmailMaskTestUser WITHOUT LOGIN;
 
GRANT SELECT ON EmailMask TO EmailMaskTestUser;
 
EXECUTE AS USER = 'EmailMaskTestUser';
SELECT * FROM EmailMask
 
REVERT;

--  Random Masking

USE Masks
 
DROP TABLE IF EXISTS RandomMask;
        
CREATE TABLE RandomMask
(
  ID	   INT IDENTITY (1,1) PRIMARY KEY NOT NULL
 ,SSN BIGINT	 MASKED WITH (FUNCTION = 'random(1,99)') NOT NULL   
 ,Age INT MASKED WITH (FUNCTION = 'random(1,9)') NOT NULL   
         
);
GO

INSERT INTO RandomMask
(
 SSN, Age
)
VALUES 
(478512369874, 56),
(697412365824, 78),
(896574123589, 28);

DROP USER IF EXISTS RandomMaskTestUser;
CREATE USER  RandomMaskTestUser WITHOUT LOGIN;
        
GRANT SELECT ON RandomMask TO RandomMaskTestUser;  
        
EXECUTE AS USER = 'RandomMaskTestUser';  
SELECT * FROM RandomMask
        
REVERT;

