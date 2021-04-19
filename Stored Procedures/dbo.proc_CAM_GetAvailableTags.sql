SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_CAM_GetAvailableTags]
(
	@uid UNIQUEIDENTIFIER
)
AS
	SET NOCOUNT ON;

	--DECLARE @uid UNIQUEIDENTIFIER
	----SELECT @uid = N'988D25DE-65E9-4FC5-8981-3D2B4EA0FEAB' -- UK
	--SELECT @uid = N'504fa7f4-85b0-4286-a24d-021e391b2d25'	-- Spain

	DECLARE @Culture NCHAR(5),
			@customerId UNIQUEIDENTIFIER,
			@customertags INT
	
	SELECT TOP 1 @Culture = up.Value, @customerId = u.CustomerID
	FROM dbo.[User] u
		INNER JOIN dbo.UserPreference up ON up.UserID = u.UserID
	WHERE u.Archived = 0 AND u.UserID = @uid AND up.NameID = 310
	
	SELECT @customertags = COUNT(*)
	FROM dbo.CAM_Tag
	WHERE CustomerId = @customerId AND Archived = 0

	--default is 'en-GB'

	SELECT 
		t.TagId, 
		t.TagTypeId, 
		t.DisplayOrder, 
		tt.Name AS TagType, 
		tt.Colour, 
		tt.IsRequiredForCoaching,
		tt.IsExclusive,
		t.Name, 
		tr.DisplayName, 
		tr.DisplayDescription
	FROM dbo.CAM_Tag t
		LEFT OUTER JOIN dbo.CAM_TagTranslation tr ON tr.TagId = t.TagId
		INNER JOIN dbo.CAM_TagType tt ON tt.TagTypeId = t.TagTypeId
	WHERE t.Archived = 0 AND tt.Archived = 0 AND tr.Archived = 0
		AND ISNULL(tr.LanguageCulture, 'en-GB') = @Culture
		AND ((@customertags = 0 AND t.CustomerId IS NULL) OR (@customertags != 0 AND t.CustomerId = @customerId))
	ORDER BY  t.TagTypeId, t.DisplayOrder

GO
