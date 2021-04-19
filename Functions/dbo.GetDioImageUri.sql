SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetDioImageUri]
(
	@uid UNIQUEIDENTIFIER,
	@ccid SMALLINT
) RETURNS NVARCHAR(512)
AS
BEGIN
	DECLARE @result NVARCHAR(512)
	
	SELECT @result = Value
	FROM dbo.UserPreference
	WHERE UserID = @uid
	AND NameID = (SELECT TOP 1 DictionaryNameId FROM dbo.DictionaryCreationCodes WHERE CreationCodeId IN (@ccid,@ccid+1) AND DictionaryCreationCodeTypeId = 4)
	
	RETURN @result
END

GO
