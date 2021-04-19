SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[IsCustomerWorkingHours] 
(
	@EventDateTime DATETIME,
	@cid UNIQUEIDENTIFIER
)
RETURNS BIT
AS
BEGIN

	--DECLARE @EventDateTime DATETIME,
	--		@cid UNIQUEIDENTIFIER
	--SET @EventDateTime = '2015-11-08 20:16'
	--SET @cid = N'471B8B63-8829-457B-B739-60704B22F1F8'
	
	DECLARE @result BIT,
			@out BIT,
			@eventtime DATETIME,
			@weekday INT,
			@dateshift SMALLINT

	-- Set @eventtime to time only part of EventDateTime
	SELECT @eventtime = DATEADD(day, -DATEDIFF(day, 0, @EventDateTime), @EventDateTime)

	-- Determine whether the local timezone has caused a day of week shift
	SELECT @dateshift = DATEDIFF(dd,MonStart,MonEnd)
	FROM dbo.WorkingHours
	WHERE CustomerID = @cid
	
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
				AND (@eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, SunStart), SunStart), '23:59:00')
							OR @eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, SunEnd), SunEnd), '00:00:00'))
			OR	@weekday = 2 -- Monday
				AND (@eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, MonStart), MonStart), '23:59:00')
							OR @eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, MonEnd), MonEnd), '00:00:00'))
			OR 	@weekday = 3 -- Tuesday
				AND (@eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, TueStart), TueStart), '23:59:00')
							OR @eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, TueEnd), TueEnd), '00:00:00'))
			OR 	@weekday = 4 -- Wednesday
				AND (@eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, WedStart), WedStart), '23:59:00')
							OR @eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, WedEnd), WedEnd), '00:00:00'))
			OR	@weekday = 5 -- Thursday
				AND (@eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, ThuStart), ThuStart), '23:59:00')
							OR @eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, ThuEnd), ThuEnd), '00:00:00'))
			OR	@weekday = 6 -- Friday
				AND (@eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, FriStart), FriStart), '23:59:00')
							OR @eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, FriEnd), FriEnd), '00:00:00'))
			OR	@weekday = 7 -- Saturday
				AND (@eventtime > ISNULL(DATEADD(day, -DATEDIFF(day, 0, SatStart), SatStart), '23:59:00')
							OR @eventtime < ISNULL(DATEADD(day, -DATEDIFF(day, 0, SatEnd), SatEnd), '00:00:00'))	
			   )
		SET @out = ISNULL(@out, 1)	
	END
	
	IF @out = 1
		SET @result = 0
	ELSE
		SET @result = 1
		
	--SELECT @result AS InWorkingHours
	RETURN @result
END






GO
