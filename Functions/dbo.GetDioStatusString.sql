SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetDioStatusString]
(
	@uid UNIQUEIDENTIFIER,
	@vid UNIQUEIDENTIFIER,
	@ccid SMALLINT,
	@onoff BIT
)
RETURNS VARCHAR(255)
AS
BEGIN
	--DECLARE @uid UNIQUEIDENTIFIER,
	--		@vid UNIQUEIDENTIFIER,
	--		@ccid SMALLINT,
	--		@onoff BIT

	--SET @uid = N'4C0A0D44-0685-4292-9087-F32E03F10134' 
	--SET @vid = N'54C0B5BD-53AE-4EC0-8625-0EC2B282DD66'
	--SET @ccid = 12
	--SET @onoff = 0

	DECLARE @result VARCHAR(255),
			@dio INT,
			@statusTypeId INT
	
	SELECT @result = CreationCodeStatus
	FROM dbo.VehicleCreationCode
	WHERE CreationCodeId = @ccid
	AND Archived = 0
	AND VehicleId = @vid
	
	SELECT @statusTypeId = 
		CASE @onoff
			WHEN 0 THEN 2
			WHEN 1 THEN 3
		END

	SELECT @dio = DictionaryNameId
	FROM dbo.DictionaryCreationCodes
	WHERE CreationCodeId in (@ccid,@ccid+1)
	AND DictionaryCreationCodeTypeId = @statusTypeId

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
