/*
Using Automated Testing to Raise Code Quality

Reloading test data
This is the way in which we might fix data that we've changed in development to ensure we have a clean development 
environment.


Copyright 2015 Steve Jones, dkRanch.net
This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.

*/

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
