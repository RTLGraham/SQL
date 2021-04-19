SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[UserPref]
	(@uid uniqueidentifier, @nameId int)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @pref VARCHAR(100)

	SELECT TOP 1 @pref = Value
	FROM [dbo].[UserPreference]
	WHERE NameId = @nameId
	AND ((UserId = @uid) OR (UserId IS NULL))
	ORDER BY UserId DESC
	
	IF @pref IS NULL
		SELECT @pref = Value
		FROM [dbo].[UserPreference]
		WHERE NameId = @nameId AND UserId IS NULL

	RETURN @pref

END

GO
