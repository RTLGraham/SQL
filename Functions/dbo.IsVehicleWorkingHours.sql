SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[IsVehicleWorkingHours] 
(
	@EventDateTime DATETIME,
	@vintid INT,
	@cid UNIQUEIDENTIFIER
)
RETURNS BIT
AS
BEGIN

	--DECLARE @EventDateTime DATETIME,
	--		@vintid INT,
	--		@cid UNIQUEIDENTIFIER
	--SET @EventDateTime = '2016-01-12 07:30'
	--SET @vintid = 120
	--SET @cid = N'36993114-90C0-4697-87E6-97C827D8765A'
	
	DECLARE @result BIT,
			@out BIT,
			@eventtime DATETIME,
			@weekday INT,
			@dateshift SMALLINT,
			@vwhid INT,
			@vehtimezone VARCHAR(35)

	-- Set @eventtime to time only part of EventDateTime
	SELECT @eventtime = DATEADD(day, -DATEDIFF(day, 0, @EventDateTime), @EventDateTime)

	-- Check for presence of vehicle working hours
	SELECT	@vwhid = vw.VehicleWorkingHoursId,
			@vehtimezone = tz.TimeZoneName
	FROM dbo.VehicleWorkingHours vw
	LEFT JOIN dbo.TZ_TimeZones tz ON tz.TimeZoneId = vw.TimeZoneId
	WHERE vw.VehicleIntId = @vintid

	-- Determine whether the local timezone has caused a day of week shift
	IF @vwhid IS NOT NULL	
		SELECT @dateshift = DATEDIFF(dd,MonStart,MonEnd)
		FROM dbo.VehicleWorkingHours
		WHERE VehicleIntId = @vintid
	ELSE		
		SELECT @dateshift = DATEDIFF(dd,MonStart,MonEnd)
		FROM dbo.WorkingHours
		WHERE CustomerID = @cid

	IF @vwhid IS NOT NULL	
	BEGIN -- use Vehicle Working Hours
	IF ISNULL(@dateshift,0) = 0 -- No Dateshift is applied
		BEGIN
	
			SELECT @weekday = DATEPART(dw, @EventDateTime) -- Just use UTC datetime as no dateshift (fast)
	
			SELECT @out = 1
			FROM dbo.VehicleWorkingHours w
			WHERE w.VehicleIntId = @vintid
			  AND  (@weekday = 1 -- Sunday
					AND (@eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, SunStart), SunStart), '23:59:00')
								OR @eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, SunEnd), SunEnd), '00:00:00'))
				OR	@weekday = 2 -- Monday
					AND (@eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, MonStart), MonStart), '23:59:00')
								OR @eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, MonEnd), MonEnd), '00:00:00'))
				OR 	@weekday = 3 -- Tuesday
					AND (@eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, TueStart), TueStart), '23:59:00')
								OR @eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, TueEnd), TueEnd), '00:00:00'))
				OR 	@weekday = 4 -- Wednesday
					AND (@eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, WedStart), WedStart), '23:59:00')
								OR @eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, WedEnd), WedEnd), '00:00:00'))
				OR	@weekday = 5 -- Thursday
					AND (@eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, ThuStart), ThuStart), '23:59:00')
								OR @eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, ThuEnd), ThuEnd), '00:00:00'))
				OR	@weekday = 6 -- Friday
					AND (@eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, FriStart), FriStart), '23:59:00')
								OR @eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, FriEnd), FriEnd), '00:00:00'))
				OR	@weekday = 7 -- Saturday
					AND (@eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, SatStart), SatStart), '23:59:00')
								OR @eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, SatEnd), SatEnd), '00:00:00'))	
				   )
			SET @out = ISNULL(@out, 0)
		END ELSE -- Dateshift is applied (so start and end times are reversed)
		BEGIN

			-- Use the vehicle timezone to identify the weekday
			SELECT @weekday = DATEPART(dw, dbo.TZ_GetTime(@EventDateTime, @vehtimezone, NULL))
	
			SELECT @out = 0
			FROM dbo.VehicleWorkingHours w
			WHERE w.VehicleIntId = @vintid
			  AND  (@weekday = 1 -- Sunday
					AND (@eventtime > ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, SunStart), SunStart), '23:59:00')
								OR @eventtime < ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, SunEnd), SunEnd), '00:00:00'))
				OR	@weekday = 2 -- Monday
					AND (@eventtime > ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, MonStart), MonStart), '23:59:00')
								OR @eventtime < ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, MonEnd), MonEnd), '00:00:00'))
				OR 	@weekday = 3 -- Tuesday
					AND (@eventtime > ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, TueStart), TueStart), '23:59:00')
								OR @eventtime < ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, TueEnd), TueEnd), '00:00:00'))
				OR 	@weekday = 4 -- Wednesday
					AND (@eventtime > ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, WedStart), WedStart), '23:59:00')
								OR @eventtime < ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, WedEnd), WedEnd), '00:00:00'))
				OR	@weekday = 5 -- Thursday
					AND (@eventtime > ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, ThuStart), ThuStart), '23:59:00')
								OR @eventtime < ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, ThuEnd), ThuEnd), '00:00:00'))
				OR	@weekday = 6 -- Friday
					AND (@eventtime > ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, FriStart), FriStart), '23:59:00')
								OR @eventtime < ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, FriEnd), FriEnd), '00:00:00'))
				OR	@weekday = 7 -- Saturday
					AND (@eventtime > ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, SatStart), SatStart), '23:59:00')
								OR @eventtime < ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, SatEnd), SatEnd), '00:00:00'))	
				   )
			SET @out = ISNULL(@out, 1)	
		END

	END ELSE -- Use Customer Working Hours
	BEGIN
		IF ISNULL(@dateshift,0) = 0 -- No Dateshift is applied
		BEGIN
	
			SELECT @weekday = DATEPART(dw, @EventDateTime) -- Just use UTC datetime as no dateshift (fast)
	
			SELECT @out = 1
			FROM dbo.WorkingHours w
			WHERE w.CustomerID = @cid
			  AND  (@weekday = 1 -- Sunday
					AND (@eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, SunStart), SunStart), '23:59:00')
								OR @eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, SunEnd), SunEnd), '00:00:00'))
				OR	@weekday = 2 -- Monday
					AND (@eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, MonStart), MonStart), '23:59:00')
								OR @eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, MonEnd), MonEnd), '00:00:00'))
				OR 	@weekday = 3 -- Tuesday
					AND (@eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, TueStart), TueStart), '23:59:00')
								OR @eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, TueEnd), TueEnd), '00:00:00'))
				OR 	@weekday = 4 -- Wednesday
					AND (@eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, WedStart), WedStart), '23:59:00')
								OR @eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, WedEnd), WedEnd), '00:00:00'))
				OR	@weekday = 5 -- Thursday
					AND (@eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, ThuStart), ThuStart), '23:59:00')
								OR @eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, ThuEnd), ThuEnd), '00:00:00'))
				OR	@weekday = 6 -- Friday
					AND (@eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, FriStart), FriStart), '23:59:00')
								OR @eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, FriEnd), FriEnd), '00:00:00'))
				OR	@weekday = 7 -- Saturday
					AND (@eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, SatStart), SatStart), '23:59:00')
								OR @eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, SatEnd), SatEnd), '00:00:00'))	
				   )
			SET @out = ISNULL(@out, 0)
		END ELSE -- Dateshift is applied (so start and end times are reversed)
		BEGIN

			-- Use Customer Preference to identify Timezone to use
			SELECT @weekday = DATEPART(dw, dbo.TZ_GetTime(@EventDateTime, dbo.CustomerPref(@cid, 3004), NULL))
	
			SELECT @out = 0
			FROM dbo.WorkingHours w
			WHERE w.CustomerID = @cid
			  AND  (@weekday = 1 -- Sunday
					AND (@eventtime > ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, SunStart), SunStart), '23:59:00')
								OR @eventtime < ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, SunEnd), SunEnd), '00:00:00'))
				OR	@weekday = 2 -- Monday
					AND (@eventtime > ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, MonStart), MonStart), '23:59:00')
								OR @eventtime < ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, MonEnd), MonEnd), '00:00:00'))
				OR 	@weekday = 3 -- Tuesday
					AND (@eventtime > ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, TueStart), TueStart), '23:59:00')
								OR @eventtime < ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, TueEnd), TueEnd), '00:00:00'))
				OR 	@weekday = 4 -- Wednesday
					AND (@eventtime > ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, WedStart), WedStart), '23:59:00')
								OR @eventtime < ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, WedEnd), WedEnd), '00:00:00'))
				OR	@weekday = 5 -- Thursday
					AND (@eventtime > ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, ThuStart), ThuStart), '23:59:00')
								OR @eventtime < ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, ThuEnd), ThuEnd), '00:00:00'))
				OR	@weekday = 6 -- Friday
					AND (@eventtime > ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, FriStart), FriStart), '23:59:00')
								OR @eventtime < ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, FriEnd), FriEnd), '00:00:00'))
				OR	@weekday = 7 -- Saturday
					AND (@eventtime > ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, SatStart), SatStart), '23:59:00')
								OR @eventtime < ISNULL(DATEADD(DAY, -DATEDIFF(DAY, 0, SatEnd), SatEnd), '00:00:00'))	
				   )
			SET @out = ISNULL(@out, 1)	
		END
	END 
	
	IF @out = 1
		SET @result = 0
	ELSE
		SET @result = 1
		
	--SELECT @result AS InWorkingHours
	RETURN @result
END










GO
