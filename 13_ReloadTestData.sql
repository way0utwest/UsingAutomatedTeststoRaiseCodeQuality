-- Use Known test data
ALTER PROCEDURE [tSalesHeader].[test Check for ship date before order date raises error]
AS
BEGIN
-- Assemble
SELECT SalesOrderId, OrderDate, shipdate, 'delay' = 1
into #expected
FROM dbo.SalesHeader
WHERE 1 = 0;


INSERT #expected
    ( SalesOrderId
    , OrderDate
    , shipdate
    , delay
    )
  VALUES
    ( 1, '2015-10-19 14:55:00', '2015-10-21 14:55:00', 2 )
	 
 -- get data from dbo.SalesHeader
-- create results table
SELECT *
 INTO #actual
 FROM #expected AS e
 WHERE 1 = 0

-- setup data
EXEC TestData.ReloadTable @tablename = 'SalesHeader'
;

-- Act
INSERT #actual
   EXEC GetShippingDateDelayForOrder @SalesOrderID = 1;

-- Assert
EXEC tsqlt.AssertEqualsTable @Expected = N'#Expected',
  @Actual = N'#Actual', 
  @FailMsg = N'The results are correct'
 
END

GO

EXEC tsqlt.run '[tSalesHeader].[test Check for ship date before order date raises error]';
GO
 
 -- get data from salesheader