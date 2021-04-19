SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[TZ_GetDayList]
	(@UTCDateTime DATETIME,
	@TimeZoneName VARCHAR(35) = NULL,
	@UserId UNIQUEIDENTIFIER = NULL,
	@DayString VARCHAR(30),
	@IsDay BIT)
RETURNS VARCHAR(30)
AS  
BEGIN 

--	DECLARE @UTCDateTime DATETIME,
--			@TimeZoneName VARCHAR(35),
--			@UserId UNIQUEIDENTIFIER,
--			@DayString VARCHAR(30),
--			@IsDay BIT
--	SET @UTCDateTime = '2013-10-17 02:00'
--	SET @TimeZoneName = NULL
--	SET @UserId = N'9ED68AB9-82A3-445F-A587-C853BDB4F3B3'
--	SET @DayString = '-1'
--	SET @IsDay = 0

	DECLARE @TZ_DateTime DATETIME,
			@DayOffset SMALLINT,
			@outString VARCHAR(30)
			
	SET @outString = @DayString

	IF @outString != ''
	BEGIN

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

		SELECT @DayOffset = DATEDIFF(dd, @UTCDateTime, @TZ_DateTime)
		
		IF @DayOffset != 0
		BEGIN
			-- Convert dayString
			DECLARE @Days TABLE
			(
				DayNum SMALLINT
			)
			
			INSERT INTO @Days (DayNum)
			SELECT VALUE FROM dbo.Split(@DayString, ',')
			
			-- Save -1 values for putting back later as have special meaning
			UPDATE @Days
			SET DayNum = 100
			WHERE DayNum = -1		
			
			UPDATE @Days
			SET DayNum = DayNum + @DayOffset
			
			IF @IsDay = 1
			BEGIN  -- correct week start and end days	
				UPDATE @Days
				SET DayNum = 7
				WHERE DayNum = 0
				
				UPDATE @Days
				SET DayNum = 1
				WHERE DayNum = 8
			END ELSE
			BEGIN -- correct month start and end dates
				UPDATE @Days
				SET DayNum = 31
				WHERE DayNum = 0
				
				UPDATE @Days
				SET DayNum = 1
				WHERE DayNum = 32
			END
			
			-- Restore -1 value Daynums as 0 meaning 'last day of the month'
			UPDATE @Days
			SET DayNum = 0
			WHERE DayNum > 90
			
			-- Rebuild output string
			SET @outString = NULL
			SELECT @outString = COALESCE(@outString + ',','') + CAST(DayNum AS VARCHAR(2))
			FROM @Days
			ORDER BY DayNum

		END -- @DayOffset != 0
		
	END -- @outString != ''
	
--	SELECT @outString
	RETURN @outString

END

GO
