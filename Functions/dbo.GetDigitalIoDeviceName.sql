SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetDigitalIoDeviceName]
(
	@dio INT,
	@uid UNIQUEIDENTIFIER,
	@vid UNIQUEIDENTIFIER
) RETURNS VARCHAR(255)
AS
BEGIN
	DECLARE @result VARCHAR(255)

	SELECT @result = vcc.Name
	FROM dbo.VehicleCreationCode vcc
	INNER JOIN dbo.DictionaryName ON vcc.CreationCodeId = CAST(Description AS INT)
	WHERE NameID = @dio
	AND vcc.VehicleId = @vid
	AND vcc.Archived = 0
	
	IF @result IS NULL
	BEGIN
		SELECT @result = Value
		FROM dbo.UserPreference 
		WHERE NameID = @dio
		AND UserID = @uid
		AND Archived = 0
	END
	
	IF @result IS NULL
	BEGIN
		SELECT @result = [Name]
		FROM dbo.DictionaryName
		WHERE NameID = @dio
		AND Archived = 0
	END
	
	RETURN @result
END

GO
