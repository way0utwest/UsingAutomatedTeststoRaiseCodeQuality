/*
Using Automated Testing to Raise Code Quality
Sample Test Data

Test data schemas and objects

NOTE: tSQLt must be installed first.

Copyright 2015 Steve Jones, dkRanch.net
This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.

*/
-- Sales Test Data

IF NOT EXISTS( SELECT * FROM sys.schemas WHERE name = 'TestData')
   EXEC('CREATE SCHEMA TestData');
GO
/*********************************************************************************************


-- test data


*********************************************************************************************/
IF OBJECT_ID('TestData.SalesHeader') IS NOT NULL
  DROP TABLE TestData.SalesHeader;
GO

CREATE TABLE TestData.SalesHeader
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


INSERT TestData.SalesHeader
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
VALUES
   ( 1, '2015-10-19 14:55:00' , '2015-10-26 14:55:00', '2015-10-21 14:55:00', 1, 0, 'AB234323', '34562', 1, 2,1, 5, 3, 200, 20, 220)
  , ( 2, '2015-10-21 9:00:00' , '2015-10-25 9:00:00', null, 1, 0, 'AB23433', '234562', 1, 2,1, 5, 3, 400, 20, 420)
--  ( 3, '2015-10-24 8:00:00' , null, null, 1, 0, 'AB234366', '44562', 1, 2,1, 5, 3, 200, 20, 220)
--, ( 4, '2015-10-28 11:30:00', '2015-11-02', '2015-11-01 10:00', 1, 0, 'RC23442', '444566', 2, 3,1, 5, 3, 500, 30, 620)
--, ( 5, '2015-11-05 12:00:00', '2015-11-15 12:00:00', '2015-11-12 12:00:00', 1, 0, 'CB23467', '464554', 3, 1,1, 5, 3, 800, 42, 820)
;

GO
IF OBJECT_ID('TestData.SalesOrderDetail') IS NOT NULL
  DROP TABLE TestData.SalesOrderDetail;
GO
CREATE TABLE TestData.SalesOrderDetail
( SalesOrderID INT
, SalesOrderDetailID INT PRIMARY KEY NONCLUSTERED
, OrderQuantity INT
, ProductID INT
, UnitPrice MONEY
, DiscountPercent VARBINARY(MAX)
, LineTotal money
, TaxAmount MONEY
, ShippingState VARCHAR(3)
);
OPEN SYMMETRIC KEY CorpSalesSymKey
  DECRYPTION BY CERTIFICATE SalesCert WITH PASSWORD = 'UseStr0ngP%ssw7rdsAl#a5ys';

INSERT INTO TestData.SalesOrderDetail
( SalesOrderID, SalesOrderDetailID, OrderQuantity, ProductID, UnitPrice, DiscountPercent, LineTotal, TaxAmount, ShippingState)
VALUES  ( 1, 1, 10, 2, 10, ENCRYPTBYKEY(KEY_GUID('CorpSalesSymKey'),'0.0'), 100, 2, 'PA')
      , ( 1, 2, 22, 3, 5, ENCRYPTBYKEY(KEY_GUID('CorpSalesSymKey'),'0.1'), 100, 5, 'GA')
      , ( 2, 3, 5, 2, 4, ENCRYPTBYKEY(KEY_GUID('CorpSalesSymKey'),'0.15'), 17, 0.85 , 'GA')
      , ( 2, 4, 12, 3, 10, ENCRYPTBYKEY(KEY_GUID('CorpSalesSymKey'),'0.1'), 108, 2.268, 'CO')
      , ( 2, 5, 5, 4, 60, ENCRYPTBYKEY(KEY_GUID('CorpSalesSymKey'),'0.0'), 300, 18.60, 'CA')
;

CLOSE ALL SYMMETRIC KEYS;
GO
IF OBJECT_ID('TestData.SalesPerson') IS NOT NULL
  DROP TABLE TestData.SalesPerson;
GO
CREATE TABLE TestData.SalesPerson
( SalesPersonID INT PRIMARY KEY NONCLUSTERED
, SalesPersonFirstName VARCHAR(100)
, SalesPersonLastName VARCHAR(100)
, SalesPersonEmail VARCHAR(500)
, TargetSales money
);
INSERT TestData.SalesPerson
        ( SalesPersonID
        , SalesPersonFirstName
        , SalesPersonLastName
		, SalesPersonEmail
		, TargetSales
        )
VALUES  ( 1, 'Bud', 'Fox', 'bud.fox@gmail.com', 20000.00 )
    , ( 2, 'Gordon', 'Gecko', 'MrBig@Wallst.com', 40000.00 )
    , ( 3, 'Carolyn', 'Gecko', 'CGecko@wallst.com', 12000.00 )
GO

IF OBJECT_ID('TestData.Products') IS NOT NULL
  DROP TABLE TestData.Products;
GO
CREATE TABLE TestData.Products
( ProductID INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED
, ProductName VARCHAR(200)
, ProductDescription VARCHAR(MAX)
, active bit
)

INSERT TestData.Products
        ( ProductName
        , ProductDescription
        , active
        )
VALUES  ( 'Widget 1', 'The best widget we produce so far', 0 )
     ,  ( 'Widget 2.0', 'An even better widget.', 1 )
     ,  ( 'Widget 3.1', 'After patches, the best widget ever.', 1 )
     ,  ( 'Widget 4.0', 'Same as it ever was', 1 );

GO
IF OBJECT_ID('TestData.ConfigValues') IS NOT NULL
  DROP TABLE TestData.ConfigValues;
GO

CREATE TABLE TestData.ConfigValues
(
  ConfigID INT IDENTITY(1,1) PRIMARY KEY
, ConfigName VARCHAR(100)
, ConfigValue VARCHAR(100)
, 
)
INSERT TestData.ConfigValues
        ( ConfigName ,ConfigValue )
VALUES  ( 'SalesTargetDoM' ,'22' )

GO
 IF OBJECT_ID('TestData.Regions') IS NOT NULL
  DROP TABLE TestData.Regions;
-- create states
CREATE TABLE TestData.Regions (
   statename VARCHAR(100),
   abbreviation VARCHAR(3) PRIMARY KEY CLUSTERED,
   countrycode VARCHAR(4)
  );
GO
INSERT  TestData.Regions
        ( statename, abbreviation, countrycode )
VALUES  ( 'Alabama', 'AL', 'USA' )
      , ( 'Montana', 'MT', 'USA' )
	  ,    ( 'Alaska', 'AK', 'USA' )
      , ( 'Nebraska', 'NE', 'USA' )
      , ( 'Arizona', 'AZ', 'USA' )
      , ( 'Nevada', 'NV', 'USA' )
      , ( 'Arkansas', 'AR', 'USA' )
      , ( 'New Hampshire', 'NH', 'USA' )
      , ( 'California', 'CA', 'USA' )
      , ( 'New Jersey', 'NJ', 'USA' )
      , ( 'Colorado', 'CO', 'USA' )
      , ( 'New Mexico', 'NM', 'USA' )
      , ( 'Connecticut', 'CT', 'USA' )
      , ( 'New York', 'NY', 'USA' )
      , ( 'Delaware', 'DE', 'USA' )
      , ( 'North Carolina', 'NC', 'USA' )
      , ( 'Florida', 'FL', 'USA' )
      , ( 'North Dakota', 'ND', 'USA' )
      , ( 'Georgia', 'GA', 'USA' )
      , ( 'Ohio', 'OH', 'USA' )
      , ( 'Hawaii', 'HI', 'USA' )
      , ( 'Oklahoma', 'OK', 'USA' )
      , ( 'Idaho', 'ID', 'USA' )
      , ( 'Oregon', 'OR', 'USA' )
      , ( 'Illinois', 'IL', 'USA' )
      , ( 'Pennsylvania', 'PA', 'USA' )
      , ( 'Indiana', 'IN', 'USA' )
      , ( 'Rhode Island', 'RI', 'USA' )
      , ( 'Iowa', 'IA', 'USA' )
      , ( 'South Carolina', 'SC', 'USA' )
      , ( 'Kansas', 'KS', 'USA' )
      , ( 'South Dakota', 'SD', 'USA' )
      , ( 'Kentucky', 'KY', 'USA' )
      , ( 'Tennessee', 'TN', 'USA' )
      , ( 'Louisiana', 'LA', 'USA' )
      , ( 'Texas', 'TX', 'USA' )
      , ( 'Maine', 'ME', 'USA' )
      , ( 'Utah', 'UT', 'USA' )
      , ( 'Maryland', 'MD', 'USA' )
      , ( 'Vermont', 'VT', 'USA' )
      , ( 'Massachusetts', 'MA', 'USA' )
      , ( 'Virginia', 'VA', 'USA' )
      , ( 'Michigan', 'MI', 'USA' )
      , ( 'Washington', 'WA', 'USA' )
      , ( 'Minnesota', 'MN', 'USA' )
      , ( 'West Virginia', 'WV', 'USA' )
      , ( 'Mississippi', 'MS', 'USA' )
      , ( 'Wisconsin', 'WI', 'USA' )
      , ( 'Missouri', 'MO', 'USA' )
      , ( 'Wyoming', 'WY', 'USA' );
GO
IF OBJECT_ID('TestData.Salestax') IS NOT NULL
  DROP TABLE TestData.Salestax;
-- Create the sales tax table
CREATE TABLE TestData.Salestax (
   statecode VARCHAR(2) PRIMARY KEY,
   taxamount NUMERIC(4, 3)
  );
GO
-- insert sales tax data
INSERT  TestData.Salestax
        ( statecode, taxamount )
VALUES  ( 'AK', 0.0714 ),
        ( 'AL', 0.0214 ),
        ( 'AR', 0.034 ),
        ( 'AZ', 0.011 ),
        ( 'CA', 0.062 ),
        ( 'CO', 0.021 ),
        ( 'CT', 0.064 ),
        ( 'DE', 0.032 ),
        ( 'FL', 0.06 ),
        ( 'GA', 0.05 ),
        ( 'HI', 0.08 ),
        ( 'IA', 0.044 ),
        ( 'ID', 0.031 ),
        ( 'IL', 0.074 ),
        ( 'IN', 0.071 ),
        ( 'KS', 0.074 ),
        ( 'KY', 0.074 ),
        ( 'LA', 0.071 ),
        ( 'MA', 0.071 ),
        ( 'MD', 0.071 ),
        ( 'ME', 0.074 ),
        ( 'MI', 0.0714 ),
        ( 'MN', 0.0714 ),
        ( 'MO', 0.0714 ),
        ( 'MS', 0.0714 ),
        ( 'MT', 0.0714 ),
        ( 'NC', 0.0714 ),
        ( 'ND', 0.0714 ),
        ( 'NE', 0.0714 ),
        ( 'NH', 0.0714 ),
        ( 'NJ', 0.0714 ),
        ( 'NM', 0.0714 ),
        ( 'NV', 0.0714 ),
        ( 'NY', 0.0714 ),
        ( 'OH', 0.0714 ),
        ( 'OK', 0.0714 ),
        ( 'OR', 0.0714 ),
        ( 'PA', 0.02 ),
        ( 'RI', 0.0714 ),
        ( 'SC', 0.0714 ),
        ( 'SD', 0.0714 ),
        ( 'TN', 0.0714 ),
        ( 'TX', 0.0714 ),
        ( 'UT', 0.0714 ),
        ( 'VA', 0.0714 ),
        ( 'VT', 0.074 ),
        ( 'WA', 0.071 ),
        ( 'WI', 0.024 ),
        ( 'WV', 0.014 ),
        ( 'WY', 0.014 );
GO
IF OBJECT_ID('TestData.EmailTemplates') IS NOT NULL
  DROP TABLE TestData.EmailTemplates;
GO
CREATE TABLE TestData.EmailTemplates
( emailtemplateid INT IDENTITY(1,1) PRIMARY KEY
, TemplateName VARCHAR(200)
, EmailSubject VARCHAR(200)
, active BIT
, msg VARCHAR(MAX)
, dataset tinyint
)
GO
INSERT  TestData.EmailTemplates
        ( TemplateName ,EmailSubject ,active ,msg ,dataset )
VALUES  ( 'Order Confirmation' ,'Order Confirmation for Order %s' ,1 ,'A long message' ,1 )
      , ( 'SalesPerson Sale Alert' ,'Monthly Sales Target Notification' ,1 ,'A really long default message' ,1 );
GO

IF OBJECT_ID('TestData.SalesCommissions') IS NOT NULL
  DROP TABLE TestData.SalesCommissions;
GO
CREATE TABLE TestData.SalesCommissions 
( SalesPersonid INT
, MinSale MONEY
, commissionrate NUMERIC(5,3)
, dataset INT
CONSTRAINT tSalesComm_PK PRIMARY KEY (SalesPersonid, MinSale)
);
GO
INSERT TestData.SalesCommissions
        ( SalesPersonid
        , MinSale
        , commissionrate
        , dataset
        )
VALUES
         ( 1, 0, 0.02, 1)
      ,  ( 1, 1000, 0.04, 1)
      ,  ( 1, 5000, 0.05, 1)
      ,  ( 2, 0, 0.02, 1)
      ,  ( 2, 1000, 0.03, 1)
      ,  ( 2, 4000, 0.04, 1)
      ,  ( 3, 500, 0.02, 1)
      ,  ( 4, 500, 0.02, 1)
 
go
IF OBJECT_ID('TestData.SaleSalesperson') IS NOT NULL
  DROP TABLE TestData.SaleSalesperson;
GO
CREATE TABLE TestData.SaleSalesperson
( SalesOrderID INT
, Salespersonid INT
CONSTRAINT tSaleSalesPerson_PK PRIMARY KEY (SalesOrderID, Salespersonid)
);
go
INSERT TestData.SaleSalesperson
        ( SalesOrderID ,Salespersonid )
VALUES  ( 1 ,1 )
     ,  ( 2 ,1 )


GO
IF OBJECT_ID('TestData.ReloadTable') IS NOT NULL
  DROP PROCEDURE TestData.ReloadTable;
GO

CREATE PROCEDURE TestData.ReloadTable
 @tablename VARCHAR(500) = 'All'
 AS
 BEGIN
 
 IF @tablename = 'SalesHeader' OR @tablename = 'ALL'
  BEGIN
    TRUNCATE TABLE dbo.SalesHeader;
	INSERT dbo.SalesHeader
	  SELECT * FROM TestData.SalesHeader AS sh
  END
 IF @tablename = 'SalesOrderDetail' OR @tablename = 'ALL'
  BEGIN
    TRUNCATE TABLE dbo.SalesOrderDetail;
	INSERT dbo.SalesOrderDetail
	  SELECT * FROM TestData.SalesOrderDetail AS sod
  END
 IF @tablename = 'SalesPerson' OR @tablename = 'ALL'
  BEGIN
    TRUNCATE TABLE dbo.SalesPerson;
	INSERT dbo.SalesPerson
	        ( SalesPersonID
	        , SalesPersonFirstName
	        , SalesPersonLastName
	        , SalesPersonEmail
	        , TargetSales
	        )
	  SELECT SP.SalesPersonID
           , SP.SalesPersonFirstName
           , SP.SalesPersonLastName
	       , SalesPersonEmail
	       , TargetSales
FROM TestData.SalesPerson AS SP
  END

 IF @tablename = 'Products' OR @tablename = 'ALL'
  BEGIN
    TRUNCATE TABLE dbo.Products;
	SET IDENTITY_INSERT dbo.Products on
	INSERT dbo.Products
	    ( ProductID, ProductName
	    , ProductDescription
	    , active
	    )
	  SELECT * FROM TestData.Products AS p 
	SET IDENTITY_INSERT dbo.Products off
  END

 IF @tablename = 'ConfigValues' OR @tablename = 'ALL'
  BEGIN
    TRUNCATE TABLE dbo.ConfigValues;
	SET IDENTITY_INSERT dbo.ConfigValues on
	INSERT dbo.ConfigValues
	        ( ConfigID, ConfigName ,ConfigValue )
	  SELECT * FROM TestData.ConfigValues
	SET IDENTITY_INSERT dbo.ConfigValues off
  END
 IF @tablename = 'Regions' OR @tablename = 'ALL'
  BEGIN
    TRUNCATE TABLE dbo.Regions;
	INSERT dbo.Regions
	        ( statename
	        , abbreviation
	        , countrycode
	        )
	  SELECT * FROM TestData.Regions
  END
 IF @tablename = 'SalesTax' OR @tablename = 'ALL'
  BEGIN
    TRUNCATE TABLE dbo.Salestax;
	INSERT dbo.Salestax
	        ( statecode ,taxamount )
	  SELECT * FROM TestData.Salestax
  END
 IF @tablename = 'EmailTeamplates' OR @tablename = 'ALL'
  BEGIN
    TRUNCATE TABLE dbo.EmailTemplates;
	SET IDENTITY_INSERT dbo.EmailTemplates ON
	INSERT dbo.EmailTemplates
	        ( emailtemplateid, TemplateName, EmailSubject, active, msg )
	  SELECT emailtemplateid
           , TemplateName
           , EmailSubject
           , active
           , msg
       FROM TestData.EmailTemplates
	   WHERE dataset = 1
	SET IDENTITY_INSERT dbo.EmailTemplates OFF
  END
 IF @tablename = 'SalesCommission' OR @tablename = 'ALL'
  BEGIN
    TRUNCATE TABLE dbo.SalesCommissions
	   INSERT dbo.SalesCommissions
	           ( SalesPersonid
	           , MinSale
	           , commissionrate
	           )
	  SELECT SalesPersonid
           , MinSale
           , commissionrate
           FROM TestData.SalesCommissions
  END

 IF @tablename = 'SaleSalesPerson' OR @tablename = 'ALL'
  BEGIN
    TRUNCATE TABLE dbo.SaleSalesperson
	
    INSERT dbo.SaleSalesPerson
	  SELECT SalesOrderID, Salespersonid
           FROM TestData.SaleSalesperson
  END


END
GO

-- TestData.ReloadTable @tablename = 'SalesCommission'
