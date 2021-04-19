SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[TZ_DayListToUTC]
	(@TZ_DateTime DATETIME,
	@TimeZoneName VARCHAR(35) = NULL,
	@UserId UNIQUEIDENTIFIER = NULL,
	@DayString VARCHAR(30),
	@IsDay BIT)
RETURNS VARCHAR(30)
AS  
BEGIN 

--	DECLARE @TZ_DateTime DATETIME,
--			@TimeZoneName VARCHAR(35),
--			@UserId UNIQUEIDENTIFIER,
--			@DayString VARCHAR(30),
--			@IsDay BIT
--	SET @TZ_DateTime = '2015-10-17 22:00'
--	SET @TimeZoneName = NULL
--	SET @UserId = N'9ED68AB9-82A3-445F-A587-C853BDB4F3B3'
--	SET @DayString = '3' --0,1,23,30'
--	SET @IsDay = 0

	DECLARE @UtcDateTime DATETIME,
			@DayOffset SMALLINT,
			@outString VARCHAR(30)
			
	SET @outString = @DayString

	IF @outString != ''
	BEGIN

		IF @TimeZoneName IS NULL
			SET @TimeZoneName = dbo.UserPref(@UserId, 600) -- TimeZoneName
			
		-- Get timezone offset
		SELECT @UtcDateTime = DATEADD(hour, -dbo.TZ_OffsetInHours(UtcOffset), @TZ_DateTime)
		FROM dbo.[TZ_TimeZones]
		WHERE TimeZoneName = @TimeZoneName

		-- Get summer time offset (if any)
		SELECT @UtcDateTime = DATEADD(hour, -dbo.TZ_OffsetInHours(DstOffset), @UtcDateTime)
		FROM dbo.[TZ_DstOffsets] dst
			INNER JOIN dbo.[TZ_TimeZones] tz ON dst.TimeZoneId = tz.TimeZoneId
		WHERE @UtcDateTime BETWEEN dst.StartDateTime AND dst.EndDateTime
			AND TimeZoneName = @TimeZoneName

		SELECT @DayOffset = DATEDIFF(dd, @TZ_DateTime, @UtcDateTime)
		
		IF @DayOffset != 0
		BEGIN
			-- Convert dayString
			DECLARE @Days TABLE
			(
				DayNum SMALLINT
			)
			
			INSERT INTO @Days (DayNum)
			SELECT VALUE FROM dbo.Split(@DayString, ',')
			
			-- Save 0 values for putting back later as have special meaning
			UPDATE @Days
			SET DayNum = 100
			WHERE DayNum = 0		
			
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
--				UPDATE @Days
--				SET DayNum = 31
--				WHERE DayNum = 0
				
				UPDATE @Days
				SET DayNum = 1
				WHERE DayNum = 32
			END
			
			-- Restore 0 value Daynums as -1 meaning 'last day of the month'
			UPDATE @Days
			SET DayNum = -1
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
