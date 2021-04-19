SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_CAM_GetAvailableCoachingOutcomes]
(
	@uid UNIQUEIDENTIFIER
)
AS
	SET NOCOUNT ON;

	--DECLARE @uid UNIQUEIDENTIFIER
	--SELECT @uid = N'988D25DE-65E9-4FC5-8981-3D2B4EA0FEAB'

	DECLARE @Culture NCHAR(5)
	
	SELECT TOP 1 @Culture = up.Value
	FROM dbo.[User] u
		INNER JOIN dbo.UserPreference up ON up.UserID = u.UserID
	WHERE u.Archived = 0 AND u.UserID = @uid AND up.NameID = 310
	
	--default is 'en-GB'

	SELECT o.CoachingOutcomeId ,
           o.DisplayOrder ,
           o.Name,
		   ot.DisplayName ,
           ot.DisplayDescription
	FROM dbo.CAM_CoachingOutcome o
		INNER JOIN dbo.CAM_CoachingOutcomeTranslation ot ON ot.CoachingOutcomeId = o.CoachingOutcomeId
	WHERE o.Archived = 0 AND ot.Archived = 0
		AND ISNULL(ot.LanguageCulture, 'en-GB') = @Culture
	ORDER BY  o.DisplayOrder

GO
