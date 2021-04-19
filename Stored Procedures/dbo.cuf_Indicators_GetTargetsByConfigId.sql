SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Indicators_GetTargetsByConfigId]
(
	@configId UNIQUEIDENTIFIER,
	@userId UNIQUEIDENTIFIER
) 
AS

SELECT i.IndicatorId, i.Name, Target =
	CASE i.IndicatorId
		WHEN 16 THEN -- Liquid Conversion
			CASE dbo.UserPref(@userid, 204)
				WHEN 0.1 THEN ic.Target * CAST(dbo.UserPref(@userid, 204) AS FLOAT)
				WHEN 0.002825 THEN CAST(dbo.UserPref(@userid, 204) AS FLOAT) * 1000000 / ic.Target
				WHEN 0.002352 THEN CAST(dbo.UserPref(@userid, 204) AS FLOAT) * 1000000 / ic.Target
				ELSE ic.Target
			END
		WHEN 17 THEN ic.Target * dbo.UserPref(@userid, 202) -- Distance Conversion
		WHEN 26 THEN ic.Target * dbo.UserPref(@userid, 208) -- Speed Conversion
		ELSE ic.Target
		END
FROM dbo.IndicatorConfig ic
	INNER JOIN dbo.Indicator i ON ic.IndicatorId = i.IndicatorId
WHERE ReportConfigurationId = @configId
ORDER BY i.IndicatorId



GO
