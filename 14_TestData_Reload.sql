-- adding row of test data.
-- open the test data file.





SELECT top 20
 * FROM  dbo.SalesHeader
GO
UPDATE dbo.SalesHeader SET statusid = 9, shipdate = NULL, AccountNumber = '12345';
GO
SELECT top 20
 * FROM  dbo.SalesHeader
GO


 
 -- get data from dbo.SalesHeaderGO
EXEC TestData.ReloadTable @tablename = 'SalesHeader';
GO



SELECT TOP 20
        *
FROM    dbo.SalesHeader;
 
 -- get data from tablename
