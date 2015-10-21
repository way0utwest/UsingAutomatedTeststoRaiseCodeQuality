USE [RaiseCodeQuality]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [SQLCop].[test Tables without a primary key]
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

