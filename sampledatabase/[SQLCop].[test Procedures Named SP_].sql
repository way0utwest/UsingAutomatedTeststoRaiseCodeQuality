USE [RaiseCodeQuality]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [SQLCop].[test Procedures Named SP_]
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
            AND e.value != 1
    Order By s.name, o.name

    EXEC tsqlt.AssertEmptyTable
      @TableName = N'#actual'
    , -- nvarchar(max)
      @Message = N'There are stored procedures named sp_' -- nvarchar(max)
    
END;

