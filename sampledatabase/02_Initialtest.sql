/*
Using Automated Testing to Raise Code Quality - 02 - Initial Tests

A set of initial tests for the database

NOTE: tSQLt must be installed first.

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
    
    Declare @Output VarChar(max)
    Set @Output = ''
  
    SELECT	@Output = @Output + SPECIFIC_SCHEMA + '.' + SPECIFIC_NAME + Char(13) + Char(10)
    From	INFORMATION_SCHEMA.ROUTINES
    Where	SPECIFIC_NAME COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI LIKE 'sp[_]%'
            And SPECIFIC_NAME COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI NOT LIKE '%diagram%'
            AND ROUTINE_SCHEMA <> 'tSQLt'
    Order By SPECIFIC_SCHEMA,SPECIFIC_NAME

    If @Output > '' 
        Begin
            Set @Output = Char(13) + Char(10) 
                          + 'For more information:  '
                          + 'http://blogs.lessthandot.com/index.php/DataMgmt/DBProgramming/MSSQLServer/don-t-start-your-procedures-with-sp_'
                          + Char(13) + Char(10) 
                          + Char(13) + Char(10) 
                          + @Output
            EXEC tSQLt.Fail @Output
        End 
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
, @tables nvarchar(4000);

-- act
SELECT @tables = COALESCE (@tables + ', ', '' ) + AllTables.name
  FROM    ( SELECT    o .name ,
                    o .object_id AS id ,
                    COALESCE( e. value, 0) AS 'PKException'
          FROM      sys.objects o
                    INNER JOIN sys.schemas s ON s. schema_id = o .schema_id
                    LEFT OUTER JOIN sys.extended_properties e ON o. object_id = e .major_id
                                                              AND e. class = 1
                                                              AND e. class_desc = 'OBJECT_OR_COLUMN'
                                                              AND e. name = 'PKException'
          WHERE     o .type = 'U'
                    AND s .name <> 'tsqlt'
        ) AS AllTables
        LEFT JOIN ( SELECT  parent_object_id
                    FROM    sys. objects
                    WHERE   type = 'PK'
                  ) AS PrimaryKeys ON AllTables .id = PrimaryKeys. parent_object_id
WHERE    PrimaryKeys. parent_object_id IS NULL
        AND AllTables .PKException = 0
ORDER BY AllTables. name;

-- assert
select @output = 'These tables need a PRIMARY key:' + @tables;
EXEC tsqlt. AssertEquals @Expected = '', @Actual = @tables, @Message = @output
END
GO



-- new test class
EXEC tsqlt.NewTestClass @ClassName = N'tSalesOrder' -- nvarchar(max)
