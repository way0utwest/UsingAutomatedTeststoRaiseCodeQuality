/*
Using Automated Testing to Raise Code Quality

Catching Exception Errors with good tests


Copyright 2015 Steve Jones, dkRanch.net
This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.

*/
EXEC tsqlt.NewTestClass @ClassName = N'tMailerTests'
GO
IF OBJECT_ID('[tMailerTests].[test SendEmailtoSalesPerson for SalesPerson Target Alert template with Carolyn Gecko token]') IS NOT NULL
    DROP PROCEDURE [tMailerTests].[test SendEmailtoSalesPerson for SalesPerson Target Alert template with Carolyn Gecko token]
GO
CREATE procedure [tMailerTests].[test SendEmailtoSalesPerson for SalesPerson Target Alert template with Carolyn Gecko token]
as
begin
  -- Assemble
  declare @expectedsubject varchar(250)
  , @actualsubject varchar(250)
  , @emailtemplate varchar(200) = 'SalesPerson Target Alert'
  , @salesid INT = 3

  SELECT @expectedsubject = 'Monthly Sales Target Notification for Carolyn Gecko'
  EXEC tsqlt.SpyProcedure @ProcedureName = N'dbo.CustomMailer' ,@CommandToExecute = N'' 

  -- Act
  EXEC dbo.SendEmailtoSalesPerson @template = @emailtemplate,@salespersonid = @salesid

  -- Assert
  SELECT @actualsubject = subject
    FROM dbo.CustomMailer_SpyProcedureLog

  EXEC tsqlt.AssertEquals
     @Expected = @expectedsubject
   , @Actual = @actualsubject 
   , @Message = N'The subject token did not work.'
 end
GO

-- test the test
EXEC tsqlt.Run '[tMailerTests].[test SendEmailtoSalesPerson for SalesPerson Target Alert template with Carolyn Gecko token]';
GO






-- things work. Let's assume this is in production and works.
-- We now get a note to change the name of the email template since we are adding a yearly alert
INSERT dbo.EmailTemplates
        ( TemplateName
        , EmailSubject
        , active
        , msg
        )
VALUES  ( 'SalesPerson Monthly Target Alert'
        , 'Monthly Sales Target Notification for %s'
        , 1
        , 'Another long default message' 
        )
UPDATE dbo.EmailTemplates
 SET active = 0
  WHERE emailtemplateid = 2
GO


-- we have some test we run for this.
-- However, before we commit, we run all our tests.
EXEC tsqlt.RunAll;
GO

-- Things are good.