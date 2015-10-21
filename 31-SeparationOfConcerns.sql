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

-- everything works

-- let's alter the procedure.
-- we decided that the sales tax is based on the pre-discount amount.
ALTER PROCEDURE dbo.SetLocalTaxRate
  @OrderId INT
AS
BEGIN
  UPDATE O 
  SET
         o.TaxAmount = (o.OrderQuantity * o.UnitPrice) * dbo.CalcSalesTaxForSale(O.ShippingState,O.LineTotal)
    FROM dbo.SalesOrderDetail AS O
   WHERE O.SalesOrderDetailID = @OrderId;    
END;
GO


-- re-test
EXEC tsqlt.run '[LocalTaxForOrderTests]'
GO


-- fails
-- why?
-- let's examine the procedure


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


-- We are using the LineTotal column only here.
-- We need to refactor the test, but this should concern us. Is there other code that depends on the 
-- Line total, and not the unit price against the discount?
-- Let's examine the SalesOrderInsert procedure

EXEC dbo.SalesOrderInsert
  @OrderId = 0
, -- int
  @qty = 0
, -- int
  @ProductID = 0
, -- int
  @UnitPrice = NULL
, -- money
  @DiscountPercent = NULL
, -- money
  @ShippingState = '' -- varchar(3)


  -- we will see failures in other code
   -- What do we do? We must comply, so we need to change all code to use pre-discount amounts for tax
  -- We are preventing potential bugs or other issues in the future by catching issues early.