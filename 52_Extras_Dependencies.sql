/*
Using Automated Testing to Raise Code Quality

Alternatives for test data - Finding Dependencies

NOTE: tSQLt must be installed first.

Copyright 2015 Steve Jones, dkRanch.net
This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.

*/
-- we have this proc
EXEC GetSalesByCustomer 1;
go
EXEC tsqlt.run 'tSalesReports';
GO

-- We want to refactor this to allow limits by month and year. Let's change the proc.
ALTER PROCEDURE dbo.GetSalesByCustomer
   @customerid int
   , @month int
 AS
 begin
 SELECT 
  customerid
  , 'SalesMonth' = DATENAME(MONTH, OrderDate)
  , 'SalesYear' = DATEPART(YEAR, OrderDate)
  , 'Total Sales' = SUM(totaldue)
 FROM   dbo.SalesHeader
 WHERE   CustomerID = @customerid
 AND DATEPART(MONTH, OrderDate) = @month
 GROUP BY CustomerID, DATEPART(YEAR, OrderDate), DATENAME(MONTH, OrderDate)
 ;
 END
 GO

EXEC GetSalesByCustomer 1, 10;
go

-- run the tests.
EXEC tsqlt.run 'tSalesReports';
GO


-- We have a problem. We have multiple procedures using this procedure.
-- We have lots of dependencies.
-- Do we want to refactor lots of procedures or add a new one.
