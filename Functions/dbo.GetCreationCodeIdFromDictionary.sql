SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetCreationCodeIdFromDictionary]
(
	@dictId INT
) RETURNS INT
AS
BEGIN
	DECLARE @result INT
	
	SELECT @result = CreationCodeId
	FROM dbo.DictionaryCreationCodes
	WHERE DictionaryNameId = @dictId
	AND DictionaryCreationCodeTypeId = 1
	
	RETURN @result
END

GO
