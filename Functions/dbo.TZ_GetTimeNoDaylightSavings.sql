SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[TZ_GetTimeNoDaylightSavings]
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

	RETURN @TZ_DateTime

END

GO
