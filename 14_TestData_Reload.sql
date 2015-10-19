-- adding row of test data.
-- open the test data file.





SELECT top 20
 * FROM  dbo.SalesHeader
 
 -- get data from dbo.SalesHeaderGO
EXEC TestData.ReloadTable @tablename = 'SalesHeader';
GO
SELECT top 20
 * FROM  tablename
 
 -- get data from tablename
