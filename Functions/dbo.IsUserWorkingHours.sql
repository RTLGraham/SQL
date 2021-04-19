SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[IsUserWorkingHours] 
(
	@EventDateTime DATETIME,
	@uid UNIQUEIDENTIFIER
)
RETURNS BIT
AS
BEGIN
--	DECLARE @EventDateTime DATETIME,
--			@uid UNIQUEIDENTIFIER
----	SET @EventDateTime = '2013-06-27 03:20'	
----	SET @uid = N'CB5C9D57-B456-4CDE-903C-2ED695E4873A'
--	SET @EventDateTime = '2014-01-26 09:01'
--	SET @uid = N'6F0B1F5F-F679-421C-9742-63D5087EC844'
	
	DECLARE @result BIT,
			@out BIT,
			@eventtime DATETIME,
			@weekday INT,
			@dateshift SMALLINT

	-- Set @eventtime to time only part of EventDateTime
	SELECT @eventtime = DATEADD(day, -DATEDIFF(day, 0, @EventDateTime), @EventDateTime)

	-- Determine whether the local timezone has caused a day of week shift
	SELECT @dateshift = DATEDIFF(dd,MonStart,MonEnd)
	FROM dbo.WorkingHours w
	INNER JOIN dbo.[User] u ON w.CustomerID = u.CustomerID
	WHERE u.UserID = @uid
	
	IF ISNULL(@dateshift,0) = 0 -- No Dateshift is applied
	BEGIN
	
		SELECT @weekday = DATEPART(dw, @EventDateTime) -- Just use UTC datetime as no dateshift (fast)
	
		SELECT @out = 1
		FROM dbo.WorkingHours w
		INNER JOIN dbo.[User] u ON w.CustomerID = u.CustomerID
		WHERE u.UserID = @uid
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
	
		SELECT @weekday = DATEPART(dw, dbo.TZ_GetTime(@EventDateTime, DEFAULT, @uid)) -- Slow but necessary for a dateshift
	
		SELECT @out = 0
		FROM dbo.WorkingHours w
		INNER JOIN dbo.[User] u ON w.CustomerID = u.CustomerID
		WHERE u.UserID = @uid
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
		
--	SELECT @result AS InWorkingHours
	RETURN @result
END






GO
