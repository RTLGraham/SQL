SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[TZ_TimeToUtc]
	(@TZ_Time TIME,
	@TZ_Date DATE = NULL,
	@TimeZoneName VARCHAR(35) = NULL,
	@UserId UNIQUEIDENTIFIER = NULL)
RETURNS TIME AS  
BEGIN 
	DECLARE @UtcTime TIME

	IF @TimeZoneName IS NULL
		SET @TimeZoneName = dbo.UserPref(@UserId, 600) -- TimeZoneName
	
	IF @TZ_Date IS NULL
		SET @TZ_Date = GETDATE()
		
	-- Get timezone offset
	SELECT @UtcTime = DATEADD(HOUR, -dbo.TZ_OffsetInHours(UtcOffset), @TZ_Time)
	FROM dbo.[TZ_TimeZones]
	WHERE TimeZoneName = @TimeZoneName

	-- Get summer time offset (if any)
	SELECT @UtcTime = DATEADD(HOUR, -dbo.TZ_OffsetInHours(DstOffset), @UtcTime)
	FROM dbo.[TZ_DstOffsets] dst
		INNER JOIN dbo.[TZ_TimeZones] tz ON dst.TimeZoneId = tz.TimeZoneId
	WHERE @TZ_Date BETWEEN dst.StartDateTime AND dst.EndDateTime
		AND TimeZoneName = @TimeZoneName

	RETURN @UtcTime

END


GO
