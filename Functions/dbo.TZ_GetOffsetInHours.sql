SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[TZ_GetOffsetInHours]
	(
		@UserId UNIQUEIDENTIFIER,
		@TZ_DateTime DATETIME
		
	)
RETURNS INT AS  
BEGIN 
	DECLARE @UtcDateTime DATETIME,
			@TimeZoneName VARCHAR(35),
			@offset INT,
			@offsetDST INT

	SET @TimeZoneName = dbo.UserPref(@UserId, 600) -- TimeZoneName
		
	-- Get timezone offset
	SELECT @offset = dbo.TZ_OffsetInHours(UtcOffset)
	FROM dbo.[TZ_TimeZones]
	WHERE TimeZoneName = @TimeZoneName

	-- Get summer time offset (if any)
	SELECT @offsetDST = dbo.TZ_OffsetInHours(DstOffset)
	FROM dbo.[TZ_DstOffsets] dst
		INNER JOIN dbo.[TZ_TimeZones] tz ON dst.TimeZoneId = tz.TimeZoneId
	WHERE @TZ_DateTime BETWEEN dst.StartDateTime AND dst.EndDateTime
		AND TimeZoneName = @TimeZoneName

	IF @offsetDST IS NULL
	BEGIN
		RETURN @offset
	END

	RETURN @offsetDST + @offset
END

GO
