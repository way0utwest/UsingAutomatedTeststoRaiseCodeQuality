/*
Using Automated Testing to Raise Code Quality

Test data options
Here we look at how test data is often handled in tests that are used for various
unit testing procedures.

Copyright 2015 Steve Jones, dkRanch.net
This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.

*/
-- Here are the example tests
CREATE PROCEDURE [tsalesheader].[test Check for ship date before order date raises error]
-- ALTER PROCEDURE [tsalesheader].[test Check for ship date before order date raises error]
AS
BEGIN
-- Assemble
CREATE TABLE #expected
( SalesOrderId INT PRIMARY KEY NONCLUSTERED
, OrderDate DATETIME
, shipdate DATETIME
, delay int
);

INSERT #expected
    ( SalesOrderId    , OrderDate    , shipdate    , delay    )  
  VALUES
    ( 1, '2015-10-19 14:55:00', '2015-10-21 14:55:00', 2 )

-- create results table
SELECT *
 INTO #actual
 FROM #expected AS e
 WHERE 1 = 0

-- setup data
EXEC tsqlt.FakeTable @TableName = N'SalesHeader', 
  @SchemaName = N'dbo';

INSERT dbo.SalesHeader
 (    SalesOrderId    , OrderDate    , duedate    , shipdate    , statusid    , OnlineOrder    , PurchaseOrderNumber    , AccountNumber
    , CustomerID    , SalesPersonID    , BilltoAddressID    , ShiptoAddressID    , ShippingMethodID    , Subtotal    , taxamount    , totaldue    )
  VALUES
    ( 1, '2015-10-19 14:55:00' , '2015-10-26 14:55:00', '2015-10-21 14:55:00', 1, 0, 'AB234323', '34562', 1, 2,1, 5, 3, 200, 20, 220)
  , ( 2, '2015-10-21 9:00:00' , '2015-10-25 9:00:00', '2015-10-22 9:00:00', 1, 0, 'AB23433', '234562', 1, 2,1, 5, 3, 400, 20, 420)


-- Act
INSERT #actual
   EXEC GetShippingDateDelayForOrder @SalesOrderID = 1;

-- Assert
EXEC tsqlt.AssertEqualsTable @Expected = N'#Expected', -- nvarchar(max)
  @Actual = N'#Actual', -- nvarchar(max)
  @FailMsg = N'The results are incorrect' -- nvarchar(max)
 
END

go

CREATE PROCEDURE [tsalesheader].[test Include Default ship date when shipdate null]
-- ALTER PROCEDURE [tsalesheader].[test Include Default ship date when shipdate null]
AS
BEGIN
-- Assemble
CREATE TABLE #expected
( SalesOrderId INT PRIMARY KEY NONCLUSTERED
, OrderDate DATETIME
, shipdate DATETIME
, delay int
);

INSERT #expected
    ( SalesOrderId    , OrderDate    , shipdate    , delay    )  
  VALUES
    ( 1, '2015-10-19 14:55:00', '2015-10-21 14:55:00', 2 )


-- create results table
SELECT *
 INTO #actual
 FROM #expected AS e
 WHERE 1 = 0

-- setup data
EXEC tsqlt.FakeTable @TableName = N'SalesHeader', 
  @SchemaName = N'dbo';

INSERT dbo.SalesHeader
   (  SalesOrderId    , OrderDate    , duedate    , shipdate    , statusid    , OnlineOrder    , PurchaseOrderNumber    , AccountNumber
    , CustomerID    , SalesPersonID    , BilltoAddressID    , ShiptoAddressID    , ShippingMethodID    , Subtotal    , taxamount    , totaldue    )
  VALUES
    ( 1, '2015-10-19 14:55:00' , '2015-10-26 14:55:00', '2015-10-21 14:55:00', 1, 0, 'AB234323', '34562', 1, 2,1, 5, 3, 200, 20, 220)
  , ( 2, '2015-10-21 9:00:00' , '2015-10-25 9:00:00', null, 1, 0, 'AB23433', '234562', 1, 2,1, 5, 3, 400, 20, 420)


-- Act
INSERT #actual
   EXEC GetShippingDateDelayForOrder @SalesOrderID = 1;

-- Assert
EXEC tsqlt.AssertEqualsTable @Expected = N'#Expected', -- nvarchar(max)
  @Actual = N'#Actual', -- nvarchar(max)
  @FailMsg = N'The results are incorrect' -- nvarchar(max)
 
END



GO

EXEC tsqlt.run '[tSalesHeader]';
GO
