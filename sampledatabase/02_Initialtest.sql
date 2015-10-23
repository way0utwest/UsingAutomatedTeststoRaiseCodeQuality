/*
Using Automated Testing to Raise Code Quality
02 - Initial Tests

A set of initial tests for the database

NOTE: tSQLt must be installed first.

Copyright 2015 Steve Jones, dkRanch.net
This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.

*/
-- setup some SQL Cop tests
EXEC tsqlt.NewTestClass @ClassName = N'SQLCop';
GO
CREATE PROCEDURE [SQLCop].[test Procedures Named SP_]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012
    -- http://sqlcop.lessthandot.com
    -- http://blogs.lessthandot.com/index.php/DataMgmt/DBProgramming/MSSQLServer/don-t-start-your-procedures-with-sp_
    
    SET NOCOUNT ON
    
-- Act  
    SELECT	'Stored Procedure Name' = s.name + '.' + o.name
	INTO #actual
    From	sys.objects o
            INNER JOIN sys.schemas s ON s.schema_id = o.schema_id
            LEFT OUTER JOIN sys.extended_properties e ON o.object_id = e.major_id
                                                              AND e.class_desc = 'OBJECT_OR_COLUMN'
                                                              AND e.name = 'sp_Exception'
    Where	o.type = 'P'
            AND s.name <> 'tsqlt'
			AND o.name COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI LIKE 'sp[_]%'
            And o.name COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI NOT LIKE '%diagram%'
            AND (e.value != 1 OR e.value IS NULL)
    Order By s.name, o.name

    EXEC tsqlt.AssertEmptyTable
      @TableName = N'#actual'
    , -- nvarchar(max)
      @Message = N'There are stored procedures named sp_' -- nvarchar(max)
    
END;
GO
CREATE PROCEDURE [SQLCop].[test Columns with float data type]
AS
BEGIN
	-- Written by George Mastros
	-- February 25, 2012
	-- http://sqlcop.lessthandot.com
	-- http://blogs.lessthandot.com/index.php/DataMgmt/DBProgramming/do-not-use-the-float-data-type
	
	SET NOCOUNT ON
	
	DECLARE @Output VarChar(max)
	SET @Output = ''
			
	SELECT 	@Output = @Output + TABLE_SCHEMA + '.' + TABLE_NAME + '.' + COLUMN_NAME + Char(13) + Char(10)
	FROM	INFORMATION_SCHEMA.COLUMNS
	WHERE	DATA_TYPE IN ('float', 'real')
			AND TABLE_SCHEMA <> 'tSQLt'
	Order By TABLE_SCHEMA,TABLE_NAME,COLUMN_NAME

	If @Output > '' 
		Begin
			Set @Output = Char(13) + Char(10) 
						  + 'For more information:  '
						  + 'http://blogs.lessthandot.com/index.php/DataMgmt/DBProgramming/do-not-use-the-float-data-type' 
						  + Char(13) + Char(10) 
						  + Char(13) + Char(10) 
						  + @Output
			EXEC tSQLt.Fail @Output
		End
	    
END;
GO
CREATE PROCEDURE [SQLCop].[test Procedures with @@Identity]
AS
BEGIN
	-- Written by George Mastros
	-- February 25, 2012
	-- http://sqlcop.lessthandot.com
	-- http://wiki.lessthandot.com/index.php/6_Different_Ways_To_Get_The_Current_Identity_Value
	
	SET NOCOUNT ON

	Declare @Output VarChar(max)
	Set @Output = ''

	Select	@Output = @Output + Schema_Name(schema_id) + '.' + name + Char(13) + Char(10)
	From	sys.all_objects
	Where	type = 'P'
			AND name Not In('sp_helpdiagrams','sp_upgraddiagrams','sp_creatediagram','testProcedures with @@Identity')
			And Object_Definition(object_id) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI Like '%@@identity%'
			And is_ms_shipped = 0
			and schema_id <> Schema_id('tSQLt')
			and schema_id <> Schema_id('SQLCop')
	ORDER BY Schema_Name(schema_id), name 

	If @Output > '' 
		Begin
			Set @Output = Char(13) + Char(10) 
						  + 'For more information:  '
						  + 'http://wiki.lessthandot.com/index.php/6_Different_Ways_To_Get_The_Current_Identity_Value'
						  + Char(13) + Char(10) 
						  + Char(13) + Char(10) 
						  + @Output
			EXEC tSQLt.Fail @Output
		End
	
END;

GO
CREATE PROCEDURE [SQLCop].[test Tables without a primary key]
AS
BEGIN

-- Assemble
DECLARE @output nvarchar(max)

-- act
SELECT AllTables.name
 INTO #actual
  FROM    ( SELECT    o.name ,
                    o.object_id AS id ,
                    COALESCE( e. value, 0) AS 'PKException'
          FROM      sys.objects o
                    INNER JOIN sys.schemas s ON s. schema_id = o.schema_id
                    LEFT OUTER JOIN sys.extended_properties e ON o.object_id = e .major_id
                                                              AND e.value = 1
                                                              AND e.class_desc = 'OBJECT_OR_COLUMN'
                                                              AND e.name = 'PKException'
          WHERE     o.type = 'U'
                    AND s.name <> 'tsqlt'
        ) AS AllTables
        LEFT JOIN ( SELECT  parent_object_id
                    FROM    sys. objects
                    WHERE   type = 'PK'
                  ) AS PrimaryKeys ON AllTables .id = PrimaryKeys. parent_object_id
WHERE    PrimaryKeys. parent_object_id IS NULL
        AND AllTables .PKException = 0
ORDER BY AllTables. name;

-- assert
EXEC tsqlt.AssertEmptyTable @TableName = N'#actual', -- nvarchar(max)
  @Message = N'There are tables without a primary key.' -- nvarchar(max)
END

GO



-- new test class
EXEC tsqlt.NewTestClass @ClassName = N'tSalesOrder' -- nvarchar(max)


EXEC tSQLt.NewTestClass 'LocalTaxForOrderTests';
GO
CREATE FUNCTION LocalTaxForOrderTests.[0.2 sales tax] (
   @state CHAR(2),
   @amount NUMERIC(12, 3)
)
RETURNS NUMERIC(12, 3)
AS
BEGIN
  RETURN 0.2;
END;
GO
CREATE PROCEDURE LocalTaxForOrderTests.[test dbo.SetLocalTaxRate uses dbo.CalcSalesTaxForSale]
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
  SELECT O.SalesOrderDetailID,O.TaxAmount
  INTO #Actual
  FROM dbo.SalesOrderDetail AS O;
  
  SELECT TOP(0) *
  INTO #Expected
  FROM #Actual;
  
  INSERT INTO #Expected
  VALUES(42,20);

  EXEC tSQLt.AssertEqualsTable '#Expected','#Actual';
END;
GO
CREATE FUNCTION LocalTaxForOrderTests.[confirm parameters(100, PA)] (
   @state CHAR(2),
   @amount NUMERIC(12, 3)
)
RETURNS NUMERIC(12, 3)
AS
BEGIN
  RETURN CASE WHEN @state = 'PA' AND @amount = 100 
           THEN 1 
           ELSE ('{@state='''+@state+''', @amount = '+CAST(@amount AS VARCHAR(MAX))+'}')/0 
         END;
END;
GO
CREATE PROCEDURE LocalTaxForOrderTests.[test dbo.SetLocalTaxRate passes correct parameters to dbo.CalcSalesTaxForSale]
AS
BEGIN
  --Assemble
  EXEC tSQLt.FakeTable @TableName = 'dbo.SalesOrderDetail';
  EXEC tSQLt.FakeFunction 
       @FunctionName = 'dbo.CalcSalesTaxForSale', 
       @FakeFunctionName = 'LocalTaxForOrderTests.[confirm parameters(100, PA)]';

  INSERT INTO dbo.SalesOrderDetail(SalesOrderDetailID,LineTotal,ShippingState)
  VALUES(42,100,'PA');

  --Act
  EXEC tSQLt.ExpectNoException;
  
  EXEC dbo.SetLocalTaxRate @OrderId = 42;

  --Assert
END;
GO

