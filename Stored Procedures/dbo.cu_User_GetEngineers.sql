SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_User_GetEngineers]
(
	@uid UNIQUEIDENTIFIER
)
AS
	--DECLARE @uid UNIQUEIDENTIFIER


	SELECT u.UserID ,
           u.Name ,
           '' as Password ,
           u.Archived ,
           u.Email ,
           u.Location ,
           u.FirstName ,
           u.Surname ,
           u.CustomerID ,
           u.ExpiryDate
	FROM dbo.[User] u
		INNER JOIN dbo.UserPreference up ON up.UserID = u.UserID
	WHERE u.Archived = 0 AND up.Archived = 0 AND up.Value = '1'
		AND up.NameID = 715
	
	 

GO
