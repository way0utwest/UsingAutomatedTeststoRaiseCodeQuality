/*
Using Automated Testing to Raise Code Quality - 1 - Standards Breaking Rules

Test data options
*/

-- We want to add a new table.
USE [RaiseCodeQuality]
GO


-- check our database for current quality
EXEC tsqlt.runall;





-- all good













-- let's build a new table.
CREATE TABLE [dbo].[SalesHeader_Staging](
	[SalesOrderId] [int] NOT NULL,
	[OrderDate] [datetime] NULL,
	[duedate] [datetime] NULL,
	[shipdate] [datetime] NULL,
	[statusid] [int] NULL,
	[OnlineOrder] [bit] NULL,
	[PurchaseOrderNumber] [varchar](100) NULL,
	[AccountNumber] [varchar](100) NULL,
	[CustomerID] [int] NULL,
	[SalesPersonID] [int] NULL,
	[BilltoAddressID] [int] NULL,
	[ShiptoAddressID] [int] NULL,
	[ShippingMethodID] [int] NULL,
	[Subtotal] [money] NULL,
	[taxamount] [money] NULL,
	[totaldue] [money] NULL,
);
GO






-- Now we re-run our standards tests.
-- We only want to run the minimal test here. We'll add more later.
EXEC tsqlt.run '[SQLCop]'
GO



-- We have a failure.


-- However, we don't want a primary key here. This is a staging table that we want to load
-- as quickly as possible.
-- Let's add an exception.

EXEC sys.sp_addextendedproperty 
  @name = 'PKException',
  @value = 1, -- sql_variant
  @level0type = 'schema', -- varchar(128)
  @level0name = 'dbo', -- sysname
  @level1type = 'table', -- varchar(128)
  @level1name = 'SalesHeader_Staging' -- sysname
  ;
GO


-- now re-test
EXEC tsqlt.run '[SQLCop]'
GO




-- If we change our mind....
EXEC sys.sp_updateextendedproperty
  @name = 'PKException'
, @value = 0
, -- sql_variant
  @level0type = 'schema'
, -- varchar(128)
  @level0name = 'dbo'
, -- sysname
  @level1type = 'table'
, -- varchar(128)
  @level1name = 'SalesHeader_Staging' -- sysname
  ;
GO





-- now re-test
EXEC tsqlt.run '[SQLCop]'
GO



/*
-- change again if wanted
EXEC sys.sp_updateextendedproperty
  @name = 'PKException'
, @value = 1
, -- sql_variant
  @level0type = 'schema'
, -- varchar(128)
  @level0name = 'dbo'
, -- sysname
  @level1type = 'table'
, -- varchar(128)
  @level1name = 'SalesHeader_Staging' -- sysname
  ;
GO

*/

-- drop table [SalesHeader_Staging]








-- optional
-- add a proc
CREATE PROCEDURE sp_test AS SELECT 1



-- test
EXEC tsqlt.run '[SQLCop]';
GO




-- fix
EXEC sys.sp_rename
  @objname = N'sp_test'
, -- nvarchar(1035)
  @newname = 'prcTest';
GO



-- test
EXEC tsqlt.run '[SQLCop]';
GO




--break
EXEC sys.sp_rename
  @objname = N'prctest'
, -- nvarchar(1035)
  @newname = 'sp_Test';
GO



-- test
EXEC tsqlt.run '[SQLCop]';
GO


-- allow an exclusion
EXEC sys.sp_addextendedproperty
  @name = 'sp_Exception'
, -- sysname
  @value = 1
, -- sql_variant
  @level0type = 'schema'
, -- varchar(128)
  @level0name = 'dbo'
, -- sysname
  @level1type = 'procedure'
, -- varchar(128)
  @level1name = 'sp_Test'
;
GO



-- test
EXEC tsqlt.run '[SQLCop]';
GO


