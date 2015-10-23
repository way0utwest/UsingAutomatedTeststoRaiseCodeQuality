-- Test test data
-- a better way of managing things.
CREATE PROCEDURE tsqlt.LoadSalesHeader
AS
BEGIN
-- setup data
EXEC tsqlt.FakeTable @TableName = N'SalesHeader', 
  @SchemaName = N'dbo';

INSERT dbo.SalesHeader
    ( SalesOrderId    , OrderDate    , duedate    , shipdate    , statusid    , OnlineOrder    , PurchaseOrderNumber
    , AccountNumber    , CustomerID    , SalesPersonID    , BilltoAddressID    , ShiptoAddressID    , ShippingMethodID
    , Subtotal    , taxamount    , totaldue
    )
  VALUES
    ( 1, '2015-10-19 14:55:00' , '2015-10-26 14:55:00', '2015-10-21 14:55:00', 1, 0, 'AB234323', '34562', 1, 2,1, 5, 3, 200, 20, 220)
  , ( 2, '2015-10-21 9:00:00' , '2015-10-25 9:00:00', null, 1, 0, 'AB23433', '234562', 1, 2,1, 5, 3, 400, 20, 420)


END


CREATE PROCEDURE [tSalesHeader].[test Check for ship date before order date raises error]
-- ALTER PROCEDURE [tSalesHeader].[test Check for ship date before order date raises error]
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
    ( SalesOrderId
    , OrderDate
    , shipdate
    , delay
    )
  VALUES
    ( 1, '2015-10-19 14:55:36.770', '2015-10-21 16:09:43.127', 2 )
	 
	 -- get data from dbo.SalesHeader
-- create results table
SELECT *
 INTO #actual
 FROM #expected AS e
 WHERE 1 = 0

-- setup data
EXEC tsqlt.LoadSalesHeader;

-- Act
INSERT #actual
   EXEC GetShippingDateDelayForOrder @SalesOrderID = 1;

-- Assert
EXEC tsqlt.AssertEqualsTable @Expected = N'#Expected',
  @Actual = N'#Actual', 
  @FailMsg = N'The results are correct'
 
END

GO

