SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[IsWorkingHours] 
(
	@EventDateTime DATETIME,
	@cid UNIQUEIDENTIFIER
)
RETURNS BIT
AS
BEGIN
--	DECLARE @cid UNIQUEIDENTIFIER,
--			@EventDateTime DATETIME
--	SET @cid = N'B5FD9DC5-2CA4-4D12-BBE0-94E070C18801'		
--	SET @EventDateTime = '2013-06-23 12:00'	
			
	DECLARE @result BIT
	DECLARE @out BIT
	
	SELECT @out = 1
	FROM dbo.WorkingHours
	WHERE CustomerID = @cid
	  AND  (DATEPART(dw, @EventDateTime) = 1 -- Sunday
			AND (DATEADD(day, -DATEDIFF(day, 0, @EventDateTime), @EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, SunStart), SunStart), '23:59:00')
						OR DATEADD(day, -DATEDIFF(day, 0, @EventDateTime), @EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, SunEnd), SunEnd), '00:00:00'))
		OR	DATEPART(dw, @EventDateTime) = 2 -- Monday
			AND (DATEADD(day, -DATEDIFF(day, 0, @EventDateTime), @EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, MonStart), MonStart), '23:59:00')
						OR DATEADD(day, -DATEDIFF(day, 0, @EventDateTime), @EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, MonEnd), MonEnd), '00:00:00'))
		OR 	DATEPART(dw, @EventDateTime) = 3 -- Tuesday
			AND (DATEADD(day, -DATEDIFF(day, 0, @EventDateTime), @EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, TueStart), TueStart), '23:59:00')
						OR DATEADD(day, -DATEDIFF(day, 0, @EventDateTime), @EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, TueEnd), TueEnd), '00:00:00'))
		OR 	DATEPART(dw, @EventDateTime) = 4 -- Wednesday
			AND (DATEADD(day, -DATEDIFF(day, 0, @EventDateTime), @EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, WedStart), WedStart), '23:59:00')
						OR DATEADD(day, -DATEDIFF(day, 0, @EventDateTime), @EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, WedEnd), WedEnd), '00:00:00'))
		OR	DATEPART(dw, @EventDateTime) = 5 -- Thursday
			AND (DATEADD(day, -DATEDIFF(day, 0, @EventDateTime), @EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, ThuStart), ThuStart), '23:59:00')
						OR DATEADD(day, -DATEDIFF(day, 0, @EventDateTime), @EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, ThuEnd), ThuEnd), '00:00:00'))
		OR	DATEPART(dw, @EventDateTime) = 6 -- Friday
			AND (DATEADD(day, -DATEDIFF(day, 0, @EventDateTime), @EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, FriStart), FriStart), '23:59:00')
						OR DATEADD(day, -DATEDIFF(day, 0, @EventDateTime), @EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, FriEnd), FriEnd), '00:00:00'))
		OR	DATEPART(dw, @EventDateTime) = 7 -- Saturday
			AND (DATEADD(day, -DATEDIFF(day, 0, @EventDateTime), @EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, SatStart), SatStart), '23:59:00')
						OR DATEADD(day, -DATEDIFF(day, 0, @EventDateTime), @EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, SatEnd), SatEnd), '00:00:00'))	
		   )

		IF @out = 1
			SET @result = 0
		ELSE
			SET @result = 1
		
--	SELECT @result
	RETURN @result
END




GO
