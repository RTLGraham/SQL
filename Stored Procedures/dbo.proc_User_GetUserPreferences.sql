SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_User_GetUserPreferences]
	@uid uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;
		
	--DECLARE @uid UNIQUEIDENTIFIER
	--SET @uid = N'e3acb89a-e2f7-4325-8f2a-c228ff9056ba'
			
	SELECT up.NameID AS [Key],
			up.Value,
			dn.Name
	FROM dbo.UserPreference up
		INNER JOIN dbo.DictionaryName dn ON dn.NameID = up.NameID
	WHERE up.UserID = @uid AND up.Archived = 0
	ORDER BY up.NameID
END;

GO
