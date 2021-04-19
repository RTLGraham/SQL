SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[TZ_ToUtc]
	(@TZ_DateTime DATETIME,
	@TimeZoneName VARCHAR(35) = NULL,
	@UserId UNIQUEIDENTIFIER = NULL)
RETURNS DATETIME AS  
BEGIN 
	DECLARE @UtcDateTime DATETIME

	IF @TimeZoneName IS NULL
		SET @TimeZoneName = dbo.UserPref(@UserId, 600) -- TimeZoneName
		
	-- Get timezone offset
	SELECT @UtcDateTime = DATEADD(MINUTE, -dbo.TZ_OffsetInMinutes(UtcOffset), @TZ_DateTime)
	FROM dbo.[TZ_TimeZones]
	WHERE TimeZoneName = @TimeZoneName

	-- Get summer time offset (if any)
	SELECT @UtcDateTime = DATEADD(MINUTE, -dbo.TZ_OffsetInMinutes(DstOffset), @UtcDateTime)
	FROM dbo.[TZ_DstOffsets] dst
		INNER JOIN dbo.[TZ_TimeZones] tz ON dst.TimeZoneId = tz.TimeZoneId
	WHERE @UtcDateTime BETWEEN dst.StartDateTime AND dst.EndDateTime
		AND TimeZoneName = @TimeZoneName

	RETURN @UtcDateTime

END

GO
