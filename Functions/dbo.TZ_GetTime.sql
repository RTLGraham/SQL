SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[TZ_GetTime]
	(@UtcDateTime DATETIME,
	@TimeZoneName VARCHAR(35) = NULL,
	@UserId UNIQUEIDENTIFIER = NULL)
RETURNS DATETIME AS  
BEGIN 
	DECLARE @TZ_DateTime DATETIME

	IF @TimeZoneName IS NULL
		SET @TimeZoneName = dbo.UserPref(@UserId, 600) -- TimeZoneName
		
	-- Get timezone offset
	SELECT @TZ_DateTime = DATEADD(minute, dbo.TZ_OffsetInMinutes(UtcOffset), @UtcDateTime)
	FROM dbo.[TZ_TimeZones]
	WHERE TimeZoneName = @TimeZoneName

	-- Get summer time offset (if any)
	SELECT @TZ_DateTime = DATEADD(minute, dbo.TZ_OffsetInMinutes(DstOffset), @TZ_DateTime)
	FROM dbo.[TZ_DstOffsets] dst
		INNER JOIN dbo.[TZ_TimeZones] tz ON dst.TimeZoneId = tz.TimeZoneId
	WHERE @TZ_DateTime BETWEEN dst.StartDateTime AND dst.EndDateTime
		AND TimeZoneName = @TimeZoneName

	RETURN @TZ_DateTime

END

GO
