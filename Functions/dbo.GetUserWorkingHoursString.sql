SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetUserWorkingHoursString] 
(
	@EventDateTime DATETIME,
	@uid UNIQUEIDENTIFIER
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
--	DECLARE @EventDateTime DATETIME,
--			@uid UNIQUEIDENTIFIER
--			
--	SET @EventDateTime = '2014-01-30 12:00'	
--	SET @uid = N'5BE41794-E1D5-442C-AE07-3B1760BA2D84'
	
	DECLARE @result NVARCHAR(MAX)
	
	SELECT @result = ISNULL(
			CASE DATEPART(dw, dbo.TZ_GetTimeNoDaylightSavings(@EventDateTime, DEFAULT, @uid))
				WHEN 1 THEN CONVERT(VARCHAR(5), dbo.TZ_GetTimeNoDaylightSavings(SunStart, DEFAULT, @uid), 108) + ':' + CONVERT(VARCHAR(5), dbo.TZ_GetTimeNoDaylightSavings(SunEnd, DEFAULT, @uid), 108)
				WHEN 2 THEN CONVERT(VARCHAR(5), dbo.TZ_GetTimeNoDaylightSavings(MonStart, DEFAULT, @uid), 108) + ':' + CONVERT(VARCHAR(5), dbo.TZ_GetTimeNoDaylightSavings(MonEnd, DEFAULT, @uid), 108)
				WHEN 3 THEN CONVERT(VARCHAR(5), dbo.TZ_GetTimeNoDaylightSavings(TueStart, DEFAULT, @uid), 108) + ':' + CONVERT(VARCHAR(5), dbo.TZ_GetTimeNoDaylightSavings(TueEnd, DEFAULT, @uid), 108)
				WHEN 4 THEN CONVERT(VARCHAR(5), dbo.TZ_GetTimeNoDaylightSavings(WedStart, DEFAULT, @uid), 108) + ':' + CONVERT(VARCHAR(5), dbo.TZ_GetTimeNoDaylightSavings(WedEnd, DEFAULT, @uid), 108)
				WHEN 5 THEN CONVERT(VARCHAR(5), dbo.TZ_GetTimeNoDaylightSavings(ThuStart, DEFAULT, @uid), 108) + ':' + CONVERT(VARCHAR(5), dbo.TZ_GetTimeNoDaylightSavings(ThuEnd, DEFAULT, @uid), 108)
				WHEN 6 THEN CONVERT(VARCHAR(5), dbo.TZ_GetTimeNoDaylightSavings(FriStart, DEFAULT, @uid), 108) + ':' + CONVERT(VARCHAR(5), dbo.TZ_GetTimeNoDaylightSavings(FriEnd, DEFAULT, @uid), 108)
				WHEN 7 THEN CONVERT(VARCHAR(5), dbo.TZ_GetTimeNoDaylightSavings(SatStart, DEFAULT, @uid), 108) + ':' + CONVERT(VARCHAR(5), dbo.TZ_GetTimeNoDaylightSavings(SatEnd, DEFAULT, @uid), 108)
			END, 'N/A')
	FROM dbo.WorkingHours w
	INNER JOIN dbo.[User] u ON w.CustomerID = u.CustomerID
	WHERE u.UserID = @uid
		
--	SELECT @result
	RETURN @result
END




GO
