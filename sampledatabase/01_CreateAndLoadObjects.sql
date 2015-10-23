/*
Using Automated Testing to Raise Code Quality
00 - Create and load objects

Objects for subsequent demos

Copyright 2015 Steve Jones, dkRanch.net
This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.

*/


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
- CREATE TABLE dbo.Regions
- CREATE TABLE dbo.Salestax

create procedures
- CREATE FUNCTION dbo.CalcSalesTaxForSale
- CREATE PROCEDURE GetShippingDateDelayForOrder 
- CREATE PROCEDURE dbo.spRegionsAdd
- CREATE PROCEDURE dbo.spRegionsUpdate
- CREATE FUNCTION dbo.UF_VerifySales
- CREATE FUNCTION dbo.UF_GetNextShippingDate
- CREATE PROCEDURE spUpdateShippingDate
- CREATE PROCEDURE dbo.SetLocalTaxRate



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
IF OBJECT_ID('dbo.ConfigValues') IS NOT NULL
  DROP TABLE dbo.ConfigValues;
GO
CREATE TABLE dbo.ConfigValues
(
  ConfigID INT IDENTITY(1,1) PRIMARY KEY
, ConfigName VARCHAR(100)
, ConfigValue VARCHAR(100)
, 
)
INSERT dbo.ConfigValues
        ( ConfigName ,ConfigValue )
VALUES  ( 'SalesTargetDoM' ,'22' )

GO
IF OBJECT_ID('dbo.SalesHeader') IS NOT NULL
  DROP TABLE dbo.SalesHeader;
GO
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
VALUES 
    ( 1, '2015-10-19 14:55:00' , '2015-10-26 14:55:00', '2015-10-21 14:55:00', 1, 0, 'AB234323', '34562', 1, 2,1, 5, 3, 200, 20, 220)
  , ( 2, '2015-10-21 9:00:00' , '2015-10-25 9:00:00', null, 1, 0, 'AB23433', '234562', 1, 2,1, 5, 3, 400, 20, 420)
;

 
 -- get data from dbo.SalesHeader
GO


CREATE TABLE SalesOrderDetail
( SalesOrderID INT
, SalesOrderDetailID INT PRIMARY KEY NONCLUSTERED
, OrderQuantity INT
, ProductID INT
, UnitPrice MONEY
, DiscountPercent VARBINARY(MAX)
, LineTotal MONEY
, TaxAmount MONEY
, ShippingState VARCHAR(3)
);
OPEN SYMMETRIC KEY CorpSalesSymKey
  DECRYPTION BY CERTIFICATE SalesCert WITH PASSWORD = 'UseStr0ngP%ssw7rdsAl#a5ys';

INSERT INTO dbo.SalesOrderDetail
( SalesOrderID, SalesOrderDetailID, OrderQuantity, ProductID, UnitPrice, DiscountPercent, LineTotal, TaxAmount, ShippingState)
VALUES  ( 1, 1, 10, 2, 10, ENCRYPTBYKEY(KEY_GUID('CorpSalesSymKey'),'0.0'), 100, 2, 'PA')
      , ( 1, 2, 22, 3, 5, ENCRYPTBYKEY(KEY_GUID('CorpSalesSymKey'),'0.1'), 100, 5, 'GA')
      , ( 2, 3, 5, 2, 4, ENCRYPTBYKEY(KEY_GUID('CorpSalesSymKey'),'0.15'), 17, 0.85 , 'GA')
      , ( 2, 4, 12, 3, 10, ENCRYPTBYKEY(KEY_GUID('CorpSalesSymKey'),'0.1'), 108, 2.268, 'CO')
      , ( 2, 5, 5, 4, 60, ENCRYPTBYKEY(KEY_GUID('CorpSalesSymKey'),'0.0'), 300, 18.60, 'CA')
;

CLOSE ALL SYMMETRIC KEYS;
GO
IF OBJECT_ID('dbo.SalesPerson') IS NOT NULL
  DROP TABLE dbo.SalesPerson;
GO
CREATE TABLE SalesPerson
( SalesPersonID INT PRIMARY KEY NONCLUSTERED
, SalesPersonFirstName VARCHAR(100)
, SalesPersonLastName VARCHAR(100)
, SalesPersonEmail VARCHAR(500)
, TargetSales money
);
INSERT dbo.SalesPerson
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

 IF OBJECT_ID('dbo.Regions') IS NOT NULL
  DROP TABLE dbo.Regions;
-- create states
CREATE TABLE dbo.Regions (
   statename VARCHAR(100),
   abbreviation VARCHAR(3) PRIMARY KEY CLUSTERED,
   countrycode VARCHAR(4)
  );
GO
INSERT  dbo.Regions
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
IF OBJECT_ID('dbo.Salestax') IS NOT NULL
  DROP TABLE dbo.Salestax;
-- Create the sales tax table
CREATE TABLE dbo.Salestax (
   statecode VARCHAR(2) PRIMARY KEY,
   taxamount NUMERIC(4, 3)
  );
GO
-- insert sales tax data
INSERT  dbo.Salestax
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


/*****************************************************
-- create procedures
*****************************************************/

IF OBJECT_ID('dbo.CalcSalesTaxForSale') IS NOT NULL
  DROP FUNCTION dbo.CalcSalesTaxForSale;
GO
-- create salestax calculation procedure
CREATE FUNCTION dbo.CalcSalesTaxForSale (
   @state CHAR(2),
   @amount NUMERIC(12, 3)
  )
RETURNS NUMERIC(12, 3)
AS
BEGIN
  DECLARE @tax NUMERIC(12, 3);

  SELECT  @tax = @amount * CASE WHEN @state = 'AK' THEN 0.05
                                WHEN @state = 'AL' THEN 0.02
                                WHEN @state = 'AR' THEN 0.04
                                WHEN @state = 'AZ' THEN 0.04
                                WHEN @state = 'CA' THEN 0.04
                                WHEN @state = 'CO' THEN 0.04
                                WHEN @state = 'CT' THEN 0.04
                                WHEN @state = 'DE' THEN 0.04
                                WHEN @state = 'FL' THEN 0.04
                                WHEN @state = 'GA' THEN 0.04
                                WHEN @state = 'HI' THEN 0.04
                                WHEN @state = 'IA' THEN 0.04
                                WHEN @state = 'ID' THEN 0.04
                                WHEN @state = 'IL' THEN 0.04
                                WHEN @state = 'IN' THEN 0.04
                                WHEN @state = 'KS' THEN 0.04
                                WHEN @state = 'KY' THEN 0.04
                                WHEN @state = 'LA' THEN 0.04
                                WHEN @state = 'MA' THEN 0.04
                                WHEN @state = 'MD' THEN 0.04
                                WHEN @state = 'ME' THEN 0.04
                                WHEN @state = 'MI' THEN 0.04
                                WHEN @state = 'MN' THEN 0.04
                                WHEN @state = 'MO' THEN 0.04
                                WHEN @state = 'MS' THEN 0.04
                                WHEN @state = 'MT' THEN 0.04
                                WHEN @state = 'NC' THEN 0.04
                                WHEN @state = 'ND' THEN 0.04
                                WHEN @state = 'NE' THEN 0.04
                                WHEN @state = 'NH' THEN 0.04
                                WHEN @state = 'NJ' THEN 0.04
                                WHEN @state = 'NM' THEN 0.04
                                WHEN @state = 'NV' THEN 0.04
                                WHEN @state = 'NY' THEN 0.04
                                WHEN @state = 'OH' THEN 0.04
                                WHEN @state = 'OK' THEN 0.04
                                WHEN @state = 'OR' THEN 0.04
                                WHEN @state = 'PS' THEN 0.02
                                WHEN @state = 'RI' THEN 0.04
                                WHEN @state = 'SC' THEN 0.04
                                WHEN @state = 'SD' THEN 0.04
                                WHEN @state = 'TN' THEN 0.04
                                WHEN @state = 'TX' THEN 0.04
                                WHEN @state = 'UT' THEN 0.04
                                WHEN @state = 'VA' THEN 0.04
                                WHEN @state = 'VT' THEN 0.04
                                WHEN @state = 'WA' THEN 0.04
                                WHEN @state = 'WI' THEN 0.04
                                WHEN @state = 'WV' THEN 0.04
                                WHEN @state = 'WY' THEN 0.04
                           END;
            
  RETURN @tax; 

END;
go

CREATE PROCEDURE GetShippingDateDelayForOrder @SalesOrderID INT
AS
    BEGIN
        SELECT  sh.SalesOrderId
              , sh.OrderDate
              , 'shipdate' = ISNULL(sh.shipdate, DATEADD( DAY, 2, sh.orderdate))
              , DATEDIFF(DAY ,sh.OrderDate ,
                         ISNULL(sh.shipdate ,DATEADD(DAY ,2 ,sh.OrderDate))) AS 'DelayDays'
        FROM    dbo.SalesHeader AS sh
        WHERE   sh.SalesOrderId = @SalesOrderID;
      

    END;
GO

IF OBJECT_ID('dbo.spRegionsAdd') IS NOT NULL
  DROP PROCEDURE dbo.spRegionsAdd;
GO
CREATE PROCEDURE dbo.spRegionsAdd
  @statename VARCHAR(100),
  @abbreviation VARCHAR(3),
  @countrycode VARCHAR(4)
AS
BEGIN TRY

  INSERT  dbo.Regions
          (
            statename,
            abbreviation,
            countrycode
          )
  VALUES  (
            @statename,
            @abbreviation,
            @countrycode
          );
END TRY
BEGIN CATCH
  THROW;
END CATCH

RETURN 
GO
IF OBJECT_ID('dbo.spRegionsUpdate') IS NOT NULL
  DROP PROCEDURE dbo.spRegionsUpdate;
GO
CREATE PROCEDURE dbo.spRegionsUpdate
  @regioncode VARCHAR(3),
  @regionname VARCHAR(200) = NULL,
  @country VARCHAR(3) = NULL
AS
UPDATE  dbo.Regions
SET     statename = @regionname,
        countrycode = @country
WHERE   abbreviation = @regioncode;

GO
IF OBJECT_ID('dbo.UF_VerifySales') IS NOT NULL DROP FUNCTION dbo.UF_VerifySales;
GO
CREATE FUNCTION dbo.UF_VerifySales ( @orderid INT )
RETURNS INT
AS
BEGIN
  DECLARE @i INT;

  IF EXISTS ( SELECT  OrderId
              FROM    dbo.Orders
              WHERE   OrderId = @orderid )
    SELECT  @i = 0
  ELSE
    SELECT  @i = 1
  RETURN @i
END

GO
-- Update Shipping date function
IF OBJECT_ID('dbo.UF_GetNextShippingDate') IS NOT NULL DROP FUNCTION dbo.UF_GetNextShippingDate;
GO
CREATE FUNCTION dbo.UF_GetNextShippingDate ( @givenDate DATETIME )
RETURNS DATETIME
AS
BEGIN
  DECLARE @workingDate DATETIME
  SELECT  @givendate = DATEADD(d, 1, @givendate);
  IF ( DATENAME(dw, @givenDate) = 'Friday' )
    BEGIN
      SET @workingDate = DATEADD(DAY, 3, @givenDate)
    END
  ELSE
    IF ( DATENAME(dw, @givenDate) = 'Saturday' )
      BEGIN
        SET @workingDate = DATEADD(DAY, 2, @givenDate)
      END
    ELSE
      BEGIN
        SET @workingDate = DATEADD(DAY, 1, @givenDate)
      END
  RETURN @workingDate
END
GO
IF OBJECT_ID('dbo.spUpdateShippingDate') IS NOT NULL DROP PROCEDURE dbo.spUpdateShippingDate;
GO
CREATE PROCEDURE dbo.spUpdateShippingDate
/*
Procedure to update shipping date for an order based on a new start date.
*/
  @orderid int,
  @currdate datetime
AS
BEGIN
  DECLARE @nextbusinessdate DATETIME;

  SELECT  @nextbusinessdate = dbo.UF_GetNextShippingDate(@currdate);

  BEGIN TRY
    UPDATE  dbo.Orders
    SET     ShippingDate = @nextbusinessdate
    WHERE   OrderId = @orderid;
  END TRY
  BEGIN CATCH
    THROW;
  END	CATCH

END
GO

IF OBJECT_ID('dbo.SetLocalTaxRate') IS NOT NULL DROP PROCEDURE dbo.SetLocalTaxRate;
GO
CREATE PROCEDURE dbo.SetLocalTaxRate
  @OrderId INT
AS
BEGIN
  UPDATE O 
  SET
         o.TaxAmount = o.LineTotal * dbo.CalcSalesTaxForSale(O.ShippingState,O.LineTotal)
    FROM dbo.SalesOrderDetail AS O
   WHERE O.SalesOrderDetailID = @OrderId;    
END;
GO

GO
IF OBJECT_ID('dbo.SalesOrderInsert') IS NOT NULL
  DROP PROCEDURE dbo.SalesOrderInsert;
GO
CREATE PROCEDURE dbo.SalesOrderInsert
  @OrderId INT
, @qty INT
, @ProductID INT
, @UnitPrice MONEY
, @DiscountPercent MONEY
, @ShippingState VARCHAR(3)
AS
  BEGIN

    OPEN SYMMETRIC KEY CorpSalesSymKey
  DECRYPTION BY CERTIFICATE SalesCert WITH PASSWORD = 'UseStr0ngP%ssw7rdsAl#a5ys';

    INSERT INTO dbo.SalesOrderDetail
        (
          SalesOrderID
        , OrderQuantity
        , ProductID
        , UnitPrice
        , DiscountPercent
		, LineTotal
		, TaxAmount
        , ShippingState
        )
        SELECT
            @OrderId
          , @qty
          , @ProductID
          , @UnitPrice
          , ENCRYPTBYKEY(KEY_GUID('CorpSalesSymKey'),
                         CAST(@DiscountPercent AS NVARCHAR(20)))
		  , (@qty * @UnitPrice) - (@qty * @UnitPrice * @DiscountPercent) 
		  , dbo.CalcSalesTaxForSale(@ShippingState, (@qty * @UnitPrice) - (@qty * @UnitPrice * @DiscountPercent))
          , @ShippingState


    CLOSE ALL SYMMETRIC KEYS;
  END

GO

IF OBJECT_ID('dbo.GetTopSalesPersonForCurrentMonth') IS NOT NULL
    DROP PROCEDURE dbo.GetTopSalesPersonForCurrentMonth;
GO
CREATE PROCEDURE GetTopSalesPersonForCurrentMonth
AS
    BEGIN
  -- get dates of current month
        DECLARE @bgdt DATE = DATEADD(MONTH ,
                                     DATEDIFF(MONTH ,'19000101' ,GETDATE()) ,
                                     '19000101')
          , @enddt DATE = DATEADD(MONTH ,
                                  DATEDIFF(MONTH ,'19000101' ,GETDATE()) + 1 ,
                                  '19000101')

        SELECT  TOP 3
		         sh.SalesPersonID
              , 'TotalSales' = SUM(sh.totaldue)
        FROM    dbo.SalesHeader sh
                INNER JOIN dbo.SalesPerson sp ON sp.SalesPersonID = sh.SalesPersonID
        GROUP BY sh.SalesPersonID

    END 


IF OBJECT_ID('dbo.CustomMailer') IS NOT NULL
    DROP PROCEDURE dbo.CustomMailer 
GO
CREATE PROCEDURE dbo.CustomMailer
    @email VARCHAR(500)
  , @msg VARCHAR(MAX)
AS
    BEGIN
        SELECT  'MailStatus' = 1
              , 'MailMsg' = 'The Email was delivered on Oct 29, 2015 at 1:30pm'
	 -- call custom mailer DLL here.
    END 


IF OBJECT_ID('dbo.SendSalesPersonSaleNotification') IS NOT NULL
    DROP PROCEDURE dbo.SendSalesPersonSaleNotification
GO
CREATE PROCEDURE dbo.SendSalesPersonSaleNotification
    @salespersonid INT
  , @sales MONEY
AS
    BEGIN
        DECLARE @target MONEY
          , @firstname VARCHAR(200)
          , @email VARCHAR(500);
   
        DECLARE @status TABLE
            (
              mailstatus INT
            , mailmsg VARCHAR(500)
            );

        SELECT  @target = TargetSales
              , @firstname = SalesPersonFirstName
              , @email = SalesPersonEmail
        FROM    dbo.SalesPerson
        WHERE   SalesPersonID = @salespersonid

        DECLARE @msg VARCHAR(MAX)

        SELECT  @msg = 'Dear ' + @firstname + CHAR(13) + CHAR(10)
                + 'Your current sales are $' + @sales
        SELECT  @msg = @msg + ', but your target is $' + @target + '.'

        INSERT  @status
                EXEC CustomMailer @email ,@msg
 
        IF ( SELECT mailstatus
             FROM   @status
           ) != 1
            EXEC CustomEmailError @status

    END
GO

IF OBJECT_ID('dbo.NotifySalespersonofSlowSales') IS NOT NULL
    DROP PROCEDURE dbo.NotifySalespersonofSlowSales
GO
CREATE PROCEDURE NotifySalespersonofSlowSales
AS
    BEGIN

        DECLARE @DoM INT;

        SELECT  @DoM = CAST(ConfigValue AS INT)
        FROM    dbo.ConfigValues
        WHERE   ConfigName = 'SalesTargetDoM';

        IF DATEPART(DAY ,GETDATE()) >= @DoM
            BEGIN	
   -- get dates of current month
                DECLARE @bgdt DATE = DATEADD(MONTH ,
                                             DATEDIFF(MONTH ,'19000101' ,
                                                      GETDATE()) ,'19000101')
                  , @enddt DATE = DATEADD(MONTH ,
                                          DATEDIFF(MONTH ,'19000101' ,
                                                   GETDATE()) + 1 ,'19000101')
                  , @salespersonid INT
                  , @totalsales MONEY
				  , @targetsales MONEY;

                DECLARE SlowSales CURSOR
                FOR
                    SELECT  sh.SalesPersonID
                          , 'TotalSales' = SUM(sh.totaldue)
                          , sp.TargetSales
                    FROM    dbo.SalesHeader sh
                            INNER JOIN dbo.SalesPerson sp ON sp.SalesPersonID = sh.SalesPersonID
                    GROUP BY sh.SalesPersonID
                          , sp.TargetSales
                    HAVING  sp.TargetSales > SUM(sh.totaldue);

				OPEN SlowSales;

                FETCH NEXT FROM SlowSales INTO @salespersonid ,@totalsales, @targetsales;
                WHILE @@FETCH_STATUS = 0
                    BEGIN
                        EXEC SendSalesPersonSaleNotification @salespersonid;
                        FETCH NEXT FROM SlowSales INTO @salespersonid ,
                            @totalsales ,
							@targetsales;
                    END;
    

            END;
		DEALLOCATE SlowSales;   
    END;
GO

IF OBJECT_ID('dbo.UF_CalcDiscountForSale') IS NOT NULL
    DROP FUNCTION dbo.UF_CalcDiscountForSale;
GO
CREATE FUNCTION dbo.UF_CalcDiscountForSale ( @QtyPurchased INT )
RETURNS NUMERIC(10 ,3)
/*
-- Test Code

select dbo.UF_CalcDiscountForSale(10);
select dbo.UF_CalcDiscountForSale(25);
select dbo.UF_CalcDiscountForSale(125);

*/
AS
    BEGIN
        DECLARE @i NUMERIC(10,3);

        SELECT  @i = CASE WHEN ( @QtyPurchased > 101 ) THEN 0.1
                          WHEN ( @QtyPurchased > 20 ) AND (@QtyPurchased < 100)
                               THEN 0.05
                          ELSE 0.0
                     END

        RETURN @i
    END

GO
