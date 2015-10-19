/*
Using Automated Testing to Raise Code Quality - 1 - Test data sample, basic loads

Test data options
*/

CREATE PROCEDURE [tsalesheader].[test Check for ship date before order date raises error]
AS
BEGIN
-- Assemble
CREATE TABLE #expected
( SalesOrderId INT PRIMARY KEY NONCLUSTERED
, OrderDate DATETIME
, shipdate DATETIME
, delay datetime
);

INSERT #expected
    ( SalesOrderId
    , OrderDate
    , shipdate
    , delay
    )
  VALUES
    ( 1, '2015-10-19 14:55:36.770', '2015-10-21 14:55:36.770', 2 
    )

-- create results table
SELECT *
 INTO #actual
 FROM #expected AS e
 WHERE 1 = 0

-- setup data
EXEC tsqlt.FakeTable @TableName = N'SalesHeader', 
  @SchemaName = N'dbo',

INSERT dbo.SalesHeader
    ( SalesOrderId
    , OrderDate
    , duedate
    , shipdate
    , statusid
    , OnlineOrder
    , PurchaseOrderNumber
    , AccountNumber
    , CustomerID
    , SalesPersonID
    , BilltoAddressID
    , ShiptoAddressID
    , ShippingMethodID
    , Subtotal
    , taxamount
    , totaldue
    )
  VALUES
    ( 1, GETDATE() , DATEADD( DAY, 7, GETDATE()), DATEADD( DAY, 2, GETDATE()), 1, 0, 'AB234323', '34562', 1, 2,1, 5, 3, 200, 20, 220)
  , ( 2, GETDATE() , DATEADD( DAY, 5, GETDATE()), DATEADD( DAY, 1, GETDATE()), 1, 0, 'AB23433', '234562', 1, 2,1, 5, 3, 400, 20, 420)


-- Act
INSERT #actual
   EXEC GetShippingDateDelayForOrder @SalesOrderID = 1;

-- Assert
EXEC tsqlt.AssertEqualsTable @Expected = N'#Expected', -- nvarchar(max)
  @Actual = N'#Actual', -- nvarchar(max)
  @Message = N'The results are correct', -- nvarchar(max)
  @FailMsg = N'The results are incorrect' -- nvarchar(max)
 
END
