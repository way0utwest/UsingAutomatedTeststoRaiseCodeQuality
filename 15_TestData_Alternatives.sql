/*
Using Automated Testing to Raise Code Quality

Alternatives for test data

NOTE: tSQLt must be installed first.

Copyright 2015 Steve Jones, dkRanch.net
This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.

*/
CREATE TABLE TestData.SalesPerson2
( SalesPersonID INT PRIMARY KEY NONCLUSTERED
, SalesPersonFirstName VARCHAR(100)
, SalesPersonLastName VARCHAR(100)
, SalesPersonEmail VARCHAR(500)
, TargetSales MONEY
, testset tinyint
);
GO
INSERT TestData.SalesPerson2
        ( SalesPersonID
        , SalesPersonFirstName
        , SalesPersonLastName
		, SalesPersonEmail
		, TargetSales
		, testset
        )
VALUES  ( 1, 'Bud', 'Fox', 'bud.fox@gmail.com', 20000.00, 1 )
    , ( 2, 'Gordon', 'Gecko', 'MrBig@Wallst.com', 40000.00, 2 )
    , ( 3, 'Carolyn', 'Gecko', 'CGecko@wallst.com', 12000.00, 2 )
GO



CREATE PROCEDURE TestData.ReloadTable2
 @tablename VARCHAR(500) = 'All'
 , @testset TINYINT = 1
 AS
 BEGIN
 
 IF @tablename = 'SalesPerson' OR @tablename = 'ALL'
  BEGIN
    TRUNCATE TABLE dbo.SalesPerson;
	INSERT dbo.SalesPerson2
	  SELECT * FROM TestData.SalesPerson AS SP
	  WHERE testset = @testset
  END

  
END


GO




-- in a test procedure

CREATE PROCEDURE [MyTests].[MyTestProc]
AS
BEGIN
    -- assemble
	EXEC tsqt.faketable 'SalesPerson2';
    EXEC TestData.ReloadTable2 @tablename = 'SalesPerson2' ,@testset = 2;

	-- Act
		
END
