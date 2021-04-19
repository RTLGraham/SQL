SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[TZ_ToUtcNoDaylightSavings]
	(@TZ_DateTime DATETIME,
	@TimeZoneName VARCHAR(35) = NULL,
	@UserId UNIQUEIDENTIFIER = NULL)
RETURNS DATETIME AS  
BEGIN 
	DECLARE @UtcDateTime DATETIME

	IF @TimeZoneName IS NULL
		SET @TimeZoneName = dbo.UserPref(@UserId, 600) -- TimeZoneName
		
	-- Get timezone offset
	SELECT @UtcDateTime = DATEADD(hour, -dbo.TZ_OffsetInHours(UtcOffset), @TZ_DateTime)
	FROM dbo.[TZ_TimeZones]
	WHERE TimeZoneName = @TimeZoneName

	RETURN @UtcDateTime

END

GO
