/*
Using Automated Testing to Raise Code Quality - 32 - SpyProcedure

*/

-- We use a custom emailer for sending mail. We have a test to look at salesperson commissions
-- we want to be sure that we can create the message without actually sending mail.  

-- let's create a test to allow us to test our procedure

EXEC tsqlt.NewTestClass @ClassName = N'tSalesPerson' -- nvarchar(max)
GO

IF OBJECT_ID('[tSalesPerson].[test Check SalesPerson Missing Target Gets Email Created]') IS NOT NULL
    DROP PROCEDURE [tSalesPerson].[test Check SalesPerson Missing Target Gets Email Created];
GO
CREATE PROCEDURE [tSalesPerson].[test Check SalesPerson Missing Target Gets Email Created]
AS 
BEGIN
    -- Assemble
	EXEC tsqlt.FakeTable @TableName = N'ConfigValues' ,@SchemaName = N'dbo';

	INSERT ConfigValues (ConfigID, ConfigName, ConfigValue)
	  SELECT 1, 'SalesTargetDoM', DATEPART(DAY, GETDATE());

	EXEC tsqlt.FakeTable @TableName = N'SalesHeader' ,@SchemaName = N'dbo';
    INSERT dbo.SalesHeader
            ( SalesOrderId
            , SalesPersonID
            , totaldue
            )
    VALUES
	  ( 1, 1, 10 )	
	, ( 2, 2, 20 )	
	, ( 3, 2, 20 );	
	
	EXEC tsqlt.FakeTable @TableName = N'SalesPerson' ,@SchemaName = N'dbo';
	INSERT dbo.SalesPerson
	        ( SalesPersonID
	        , TargetSales
	        )
	VALUES  ( 1, 5)
	      , ( 2, 50);

	EXEC tsqlt.SpyProcedure @ProcedureName = N'SendSalesPersonSaleNotification' ,@CommandToExecute = N'';
	
	-- Act
    EXEC NotifySalespersonofSlowSales;

	-- Assert
	SELECT salespersonid
	 INTO #expected
	 FROM dbo.SendSalesPersonSaleNotification_SpyProcedureLog
	 WHERE 1 = 0;

	INSERT #expected SELECT 2;

	SELECT salespersonid
	 INTO #actual
	 FROM dbo.SendSalesPersonSaleNotification_SpyProcedureLog;


	EXEC tsqlt.AssertEqualsTable @Expected = N'#expected' ,@Actual = N'#actual' ,@FailMsg = N'The salesperson information is incorrect.';
	
END;

GO
EXEC tsqlt.run '[tSalesPerson].[test Check SalesPerson Missing Target Gets Email Created]';
