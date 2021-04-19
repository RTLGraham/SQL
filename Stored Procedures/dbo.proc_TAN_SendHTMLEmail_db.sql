SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_TAN_SendHTMLEmail_db] 
	@aRecipient NVARCHAR(4000), @aSubject NVARCHAR(4000), @aBodyText NVARCHAR(MAX)
AS

DECLARE @profile VARCHAR(50)

SELECT @profile = Value 
FROM dbo.DBConfig
WHERE NameID = 9004

IF @profile IS NULL	SET @profile = 'Fleetwise General Mail' -- default

SELECT @profile

EXEC msdb.dbo.sp_send_dbmail
    @profile_name = @profile,
    @recipients = @aRecipient,
    @subject = @aSubject,
    @body_format = 'HTML',
    @body = @aBodyText


GO
