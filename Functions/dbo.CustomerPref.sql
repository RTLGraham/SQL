SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[CustomerPref]
	(@cid UNIQUEIDENTIFIER, @nameId INT)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @pref VARCHAR(100)

	SELECT TOP 1 @pref = Value
	FROM [dbo].[CustomerPreference]
	WHERE NameId = @nameId
	AND ((CustomerId = @cid) OR (CustomerId IS NULL))
	ORDER BY CustomerId DESC
	
	IF @pref IS NULL
		SELECT @pref = Value
		FROM [dbo].[CustomerPreference]
		WHERE NameId = @nameId AND CustomerId IS NULL

	RETURN @pref

END


GO
