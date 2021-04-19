SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_CheckSSOByUserName] (@username VARCHAR(512))
AS	
BEGIN	

	--DECLARE @username VARCHAR(512)
	--SET @username = 'chrauti'

	SELECT DISTINCT c.CustomerId, c.Name AS CustomerName, c.SSO_clientId, c.SSO_clientSecret, c.SSO_directoryId
	FROM dbo.[User] u
	INNER JOIN dbo.Customer c ON c.CustomerId = u.CustomerID
	WHERE u.Name = @username
	  AND u.IsADSyncDisabled = 0
	  AND c.IsSSOEnabled = 1

END	

GO
