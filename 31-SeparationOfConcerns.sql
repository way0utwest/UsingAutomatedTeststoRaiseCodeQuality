/* 

Raising Code Quality with Automated Testing
Separation of Concerns

This example shows how you can use FakeTable and FakeFunction to separate the logic
you want to test from unrelated parts of the product.

Requirements

Copyright 2015, Sebastian Meine and Steve Jones

This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.

*/
EXEC tsqlt.run '[LocalTaxForOrderTests]'
GO

-- everything works


-- Let's change the function in the procedure.
-- Alter the tax code for PA. However, we make a mistake.
ALTER FUNCTION [dbo].[CalcSalesTaxForSale] (
   @state CHAR(2),
   @amount NUMERIC(12, 3)
  )
RETURNS NUMERIC(12, 3)
AS
BEGIN
  DECLARE @tax NUMERIC(12, 3);

  SELECT  @tax = @amount * CASE WHEN @state = 'AK' THEN 0.05
                                WHEN @state = 'AL' THEN 0.02
                                WHEN @state = 'AR' THEN 0.04
                                WHEN @state = 'AZ' THEN 0.04
                                WHEN @state = 'CA' THEN 0.04
                                WHEN @state = 'CO' THEN 0.04
                                WHEN @state = 'CT' THEN 0.04
                                WHEN @state = 'DE' THEN 0.04
                                WHEN @state = 'FL' THEN 0.04
                                WHEN @state = 'GA' THEN 0.04
                                WHEN @state = 'HI' THEN 0.04
                                WHEN @state = 'IA' THEN 0.04
                                WHEN @state = 'ID' THEN 0.04
                                WHEN @state = 'IL' THEN 0.04
                                WHEN @state = 'IN' THEN 0.04
                                WHEN @state = 'KS' THEN 0.04
                                WHEN @state = 'KY' THEN 0.04
                                WHEN @state = 'LA' THEN 0.04
                                WHEN @state = 'MA' THEN 0.04
                                WHEN @state = 'MD' THEN 0.04
                                WHEN @state = 'ME' THEN 0.04
                                WHEN @state = 'MI' THEN 0.04
                                WHEN @state = 'MN' THEN 0.04
                                WHEN @state = 'MO' THEN 0.04
                                WHEN @state = 'MS' THEN 0.04
                                WHEN @state = 'MT' THEN 0.04
                                WHEN @state = 'NC' THEN 0.04
                                WHEN @state = 'ND' THEN 0.04
                                WHEN @state = 'NE' THEN 0.04
                                WHEN @state = 'NH' THEN 0.04
                                WHEN @state = 'NJ' THEN 0.04
                                WHEN @state = 'NM' THEN 0.04
                                WHEN @state = 'NV' THEN 0.04
                                WHEN @state = 'NY' THEN 0.04
                                WHEN @state = 'OH' THEN 0.04
                                WHEN @state = 'OK' THEN 0.04
                                WHEN @state = 'OR' THEN 0.04
                                WHEN @state = 'PS' THEN 0.02
                                WHEN @state = 'RI' THEN 0.04
                                WHEN @state = 'SC' THEN 0.04
                                WHEN @state = 'SD' THEN 0.04
                                WHEN @state = 'TN' THEN 0.04
                                WHEN @state = 'TX' THEN 0.04
                                WHEN @state = 'UT' THEN 0.04
                                WHEN @state = 'VA' THEN 0.04
                                WHEN @state = 'VT' THEN 0.04
                                WHEN @state = 'WA' THEN 0.04
                                WHEN @state = 'WI' THEN 0.04
                                WHEN @state = 'WV' THEN 0.04
                                WHEN @state = 'WY' THEN 0.04
                           END;
            
  RETURN @tax; 

END;
GO

-- re-run the test
EXEC tsqlt.run '[LocalTaxForOrderTests]';
GO


-- Still passes. We are not brittle here.

-- This still catches errors.
-- let's alter the procedure.
-- we decided that the sales tax is based on the pre-discount amount.
ALTER PROCEDURE dbo.SetLocalTaxRate
  @OrderId INT
AS
BEGIN
  UPDATE O 
  SET
         o.TaxAmount = (o.OrderQuantity * o.UnitPrice) * dbo.CalcSalesTaxForSale(O.ShippingState,o.OrderQuantity * o.UnitPrice)
    FROM dbo.SalesOrderDetail AS O
   WHERE O.SalesOrderDetailID = @OrderId;    
END;
GO


-- re-test
EXEC tsqlt.run '[LocalTaxForOrderTests]'
GO


-- fails
-- why?
-- let's examine the test procedure
-- Look at the calculation. The function uses a different value
-- The Line total has a discount, where the new proc being tested uses qty*price
-- This is the current test code.
ALTER PROCEDURE [LocalTaxForOrderTests].[test dbo.SetLocalTaxRate uses dbo.CalcSalesTaxForSale]
AS
BEGIN
  --Assemble
  EXEC tSQLt.FakeTable @TableName = 'dbo.SalesOrderDetail';
  EXEC tSQLt.FakeFunction 
       @FunctionName = 'dbo.CalcSalesTaxForSale', 
       @FakeFunctionName = 'LocalTaxForOrderTests.[0.2 sales tax]';

  INSERT INTO dbo.SalesOrderDetail(SalesOrderDetailID,LineTotal,ShippingState)
  VALUES(42,100,'PA');

  --Act
  EXEC dbo.SetLocalTaxRate @OrderId = 42;

  --Assert
  SELECT sod.SalesOrderDetailID,sod.TaxAmount
  INTO #Actual
  FROM dbo.SalesOrderDetail AS sod;
  
  SELECT TOP(0) *
  INTO #Expected
  FROM #Actual;
  
  INSERT INTO #Expected
  VALUES(42,20);

  EXEC tSQLt.AssertEqualsTable '#Expected','#Actual';
END;
go

-- We need to alter the procedure with new column data
ALTER PROCEDURE [LocalTaxForOrderTests].[test dbo.SetLocalTaxRate uses dbo.CalcSalesTaxForSale]
AS
BEGIN
  --Assemble
  EXEC tSQLt.FakeTable @TableName = 'dbo.SalesOrderDetail';
  EXEC tSQLt.FakeFunction 
       @FunctionName = 'dbo.CalcSalesTaxForSale', 
       @FakeFunctionName = 'LocalTaxForOrderTests.[0.2 sales tax]';

  INSERT INTO dbo.SalesOrderDetail(SalesOrderDetailID,LineTotal,ShippingState, unitprice, OrderQuantity)
  VALUES(42,100,'PA', 20, 5);

  --Act
  EXEC dbo.SetLocalTaxRate @OrderId = 42;

  --Assert
  SELECT sod.SalesOrderDetailID,sod.TaxAmount
  INTO #Actual
  FROM dbo.SalesOrderDetail AS sod;
  
  SELECT TOP(0) *
  INTO #Expected
  FROM #Actual;
  
  INSERT INTO #Expected
  VALUES(42,20);

  EXEC tSQLt.AssertEqualsTable '#Expected','#Actual';
END;
go
-- Rerun the test
EXEC tsqlt.run '[LocalTaxForOrderTests]'



-- Examine the Procedure at the top.
-- We are using the LineTotal column only here.
-- We need to refactor the test, but this should concern us. Is there other code that depends on the 
-- Line total, and not the unit price against the discount?
-- Let's examine the SalesOrderInsert procedure

ALTER PROCEDURE [dbo].[SalesOrderInsert]
  @OrderId INT
, @qty INT
, @ProductID INT
, @UnitPrice MONEY
, @DiscountPercent MONEY
, @ShippingState VARCHAR(3)
AS
  BEGIN

    OPEN SYMMETRIC KEY CorpSalesSymKey
  DECRYPTION BY CERTIFICATE SalesCert WITH PASSWORD = 'UseStr0ngP%ssw7rdsAl#a5ys';

    INSERT INTO dbo.SalesOrderDetail
        (
          SalesOrderID
        , OrderQuantity
        , ProductID
        , UnitPrice
        , DiscountPercent
		, LineTotal
		, TaxAmount
        , ShippingState
        )
        SELECT
            @OrderId
          , @qty
          , @ProductID
          , @UnitPrice
          , ENCRYPTBYKEY(KEY_GUID('CorpSalesSymKey'),
                         CAST(@DiscountPercent AS NVARCHAR(20)))
		  , (@qty * @UnitPrice) - (@qty * @UnitPrice * @DiscountPercent) 
		  , dbo.CalcSalesTaxForSale(@ShippingState, (@qty * @UnitPrice) - (@qty * @UnitPrice * @DiscountPercent))
          , @ShippingState


    CLOSE ALL SYMMETRIC KEYS;
  END
-- we are calculating tax on the discount amount.
-- we will see failures in other code
-- What do we do? We must comply, so we need to change all code to use pre-discount amounts for tax
-- We are preventing potential bugs or other issues in the future by catching issues early.
