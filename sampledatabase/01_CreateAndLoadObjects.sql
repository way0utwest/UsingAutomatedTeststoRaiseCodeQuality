/*
Setup for sample query database

create cryptographics
- certificate SalesCert 
- symmetric key CorpSalesSymKey

create schemas
- create schema tSalesHeader
- create schema tSalesOrderDetail
- create schema tSalesReports


create tables
- CREATE TABLE SalesHeader
- CREATE TABLE SalesOrderDetail
- CREATE TABLE SalesPerson
- CREATE TABLE Products

create procedures
- CREATE PROCEDURE GetShippingDateDelayForOrder 

*/
-- create cryptographics
create certificate SalesCert ENCRYPTION BY PASSWORD = 'UseStr0ngP%ssw7rdsAl#a5ys' WITH SUBJECT = 'SalesDiscountCert';

create symmetric key CorpSalesSymKey
with algorithm = AES_256
, IDENTITY_VALUE = 'The Redgate SQL Prompt Challenge'
, KEY_SOURCE = 'The Hitchikers Guid'
ENCRYPTION BY CERTIFICATE Salescert;
GO


-- create schemas
EXEC tsqlt.NewTestClass @ClassName = N'tSalesHeader';
GO
EXEC tsqlt.NewTestClass @ClassName = N'tSalesOrderDetail';
GO
EXEC tsqlt.NewTestClass @ClassName = N'tSalesReports';
GO


-- create tables

CREATE TABLE SalesHeader
( SalesOrderId INT PRIMARY KEY NONCLUSTERED
, OrderDate DATETIME
, duedate DATETIME
, shipdate DATETIME
, statusid INT
, OnlineOrder BIT
, PurchaseOrderNumber VARCHAR(100)
, AccountNumber VARCHAR(100)
, CustomerID INT
, SalesPersonID INT
, BilltoAddressID INT
, ShiptoAddressID INT
, ShippingMethodID INT
, Subtotal MONEY
, taxamount MONEY
, totaldue MONEY
);
INSERT dbo.SalesHeader
        ( SalesOrderId
        , OrderDate
        , duedate
        , shipdate
        , statusid
        , OnlineOrder
        , PurchaseOrderNumber
        , AccountNumber
        , CustomerID
        , SalesPersonID
        , BilltoAddressID
        , ShiptoAddressID
        , ShippingMethodID
        , Subtotal
        , taxamount
        , totaldue
        )
VALUES  ( 1, GETDATE() , DATEADD( DAY, 7, GETDATE()), DATEADD( DAY, 2, GETDATE()), 1, 0, 'AB234323', '34562', 1, 2,1, 5, 3, 200, 20, 220)
      , ( 2, GETDATE() , DATEADD( DAY, 5, GETDATE()), DATEADD( DAY, 1, GETDATE()), 1, 0, 'AB23433', '234562', 1, 2,1, 5, 3, 400, 20, 420)
;

GO


CREATE TABLE SalesOrderDetail
( SalesOrderID INT
, SalesOrderDetailID INT PRIMARY KEY NONCLUSTERED
, OrderQuantity INT
, ProductID INT
, UnitPrice MONEY
, DiscountPercent VARBINARY(MAX)
, LineTotal money
);
OPEN SYMMETRIC KEY CorpSalesSymKey
  DECRYPTION BY CERTIFICATE SalesCert WITH PASSWORD = 'UseStr0ngP%ssw7rdsAl#a5ys';

INSERT INTO dbo.SalesOrderDetail
( SalesOrderID, SalesOrderDetailID, OrderQuantity, ProductID, UnitPrice, DiscountPercent, LineTotal)
VALUES  ( 1, 1, 10, 2, 10, ENCRYPTBYKEY(KEY_GUID('CorpSalesSymKey'),'0.0'), 100)
      , ( 1, 2, 22, 3, 5, ENCRYPTBYKEY(KEY_GUID('CorpSalesSymKey'),'0.1'), 100)
      , ( 2, 3, 5, 2, 4, ENCRYPTBYKEY(KEY_GUID('CorpSalesSymKey'),'0.15'), 17)
      , ( 2, 4, 12, 3, 10, ENCRYPTBYKEY(KEY_GUID('CorpSalesSymKey'),'0.1'), 108)
      , ( 2, 5, 5, 4, 60, ENCRYPTBYKEY(KEY_GUID('CorpSalesSymKey'),'0.0'), 300)
;
CLOSE ALL SYMMETRIC KEYS;
GO
CREATE TABLE SalesPerson
( SalesPersonID INT PRIMARY KEY NONCLUSTERED
, SalesPersonFirstName VARCHAR(100)
, SalesPersonLastName VARCHAR(100)
);
INSERT dbo.SalesPerson
        ( SalesPersonID
        , SalesPersonFirstName
        , SalesPersonLastName
        )
VALUES  ( 1, 'David', 'Smith' )
    , ( 2, 'Gordon', 'Gecko' )
GO


GO
CREATE TABLE Products
( ProductID INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED
, ProductName VARCHAR(200)
, ProductDescription VARCHAR(MAX)
, active bit
)

INSERT dbo.Products
        ( ProductName
        , ProductDescription
        , active
        )
VALUES  ( 'Widget 1', 'The best widget we produce so far', 0 )
     ,  ( 'Widget 2.0', 'An even better widget.', 1 )
     ,  ( 'Widget 3.1', 'After patches, the best widget ever.', 1 )
     ,  ( 'Widget 4.0', 'Same as it ever was', 1 );

GO
/*****************************************************
-- create procedures
*****************************************************/

CREATE PROCEDURE GetShippingDateDelayForOrder 
@SalesOrderID int
AS
BEGIN
SELECT sh.SalesOrderId
     , sh.OrderDate
	 , sh.shipdate
	 , DATEDiff(DAY, sh.OrderDate, sh.shipdate) AS 'DelayDays'
 FROM dbo.SalesHeader AS sh
 WHERE sh.SalesOrderId = @SalesOrderID
      

END



 