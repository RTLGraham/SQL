SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetTargetByIndicatorConfigId]
(
	@indicatorid TINYINT,
	@configId UNIQUEIDENTIFIER,
	@userId UNIQUEIDENTIFIER
) 
RETURNS FLOAT
AS
BEGIN
	DECLARE @Target FLOAT

	SELECT @Target =
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
	  AND i.IndicatorId = @indicatorid
	  
	RETURN @Target
	
END


GO
