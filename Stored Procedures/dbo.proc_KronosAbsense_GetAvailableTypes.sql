SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_KronosAbsense_GetAvailableTypes]
(
	@uid UNIQUEIDENTIFIER
)
AS
	SET NOCOUNT ON;

	--DECLARE @uid UNIQUEIDENTIFIER
	--SELECT @uid = N'E3ACB89A-E2F7-4325-8F2A-C228FF9056BA'

	DECLARE @Culture NCHAR(5)
	
	SELECT TOP 1 @Culture = ISNULL(up.Value, 'en-GB')
	FROM dbo.[User] u
		INNER JOIN dbo.UserPreference up ON up.UserID = u.UserID
	WHERE u.Archived = 0 AND u.UserID = @uid AND up.NameID = 310
	
	--default is 'en-GB'

	SELECT 
		t.KronosAbsenseTypeId,
		t.DisplayOrder,
		tr.DisplayName,
		tr.DisplayDescription,
		t.CommentReq
	FROM dbo.KronosAbsenseType t
		INNER JOIN dbo.KronosAbsenseTypeTranslation tr ON tr.KronosAbsenseTypeId = t.KronosAbsenseTypeId
	WHERE t.Archived = 0 AND tr.Archived = 0
		AND ISNULL(tr.LanguageCulture, 'en-GB') = @Culture
	ORDER BY  t.DisplayOrder


GO
