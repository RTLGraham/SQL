SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_UserPreference_UpdateByUserId]
(
	@userID UNIQUEIDENTIFIER,
	@nameID INT,
	@newPrefValue NVARCHAR(MAX)
)
AS

	DECLARE  
		@luserID UNIQUEIDENTIFIER,
		@lnameID INT,
		@lnewPrefValue NVARCHAR(MAX)


	--DECLARE
	--	@userID uniqueidentifier,
	--	@nameID int,
	--	@newPrefValue nvarchar(max)
	--set @userID = N'DBF1D1D6-8C0C-4C43-AA55-6C2DA0AB61CB'
	--set @nameID = 201
	--set @newPrefValue = 'Gallon'


	SET @luserID = @userID
	SET @lnameID = @nameID
	SET @lnewPrefValue = @newPrefValue

	UPDATE dbo.[UserPreference]
    SET [Value] = @lnewPrefValue
	WHERE [UserID] = @luserID AND [NameID] = @lnameID

	SELECT 
	p.NameID,
	p.Value
	FROM dbo.UserPreference p
	WHERE [UserID] = @luserID AND [NameID] = @lnameID

GO
