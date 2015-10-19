/*
Using Automated Testing to Raise Code Quality - 1 - Standards Breaking Rules

Test data options
*/

-- We want to add a new table.
USE [RaiseCodeQuality]
GO
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





-- run our tests.
EXEC tsqlt.runall

