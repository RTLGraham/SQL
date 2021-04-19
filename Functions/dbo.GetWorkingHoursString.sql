SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetWorkingHoursString] 
(
	@EventDateTime DATETIME,
	@cid UNIQUEIDENTIFIER,
  @uid UNIQUEIDENTIFIER
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	--DECLARE @cid UNIQUEIDENTIFIER,
	--		@EventDateTime DATETIME,
	--		@uid UNIQUEIDENTIFIER
			
	--SET @cid = N'AEB8160F-7C23-410E-BB45-EE61DE7B82C9'		
	--SET @EventDateTime = '2013-06-21 12:00'	
	--SET @uid = N'8457C288-CBF2-4A49-A5BD-97C4BE8561B3'
	
	DECLARE @result NVARCHAR(MAX)
	
	SELECT @result = ISNULL(
			CASE DATEPART(dw, @EventDateTime)
				WHEN 1 THEN CONVERT(VARCHAR(5), dbo.TZ_GetTime(SunStart, DEFAULT, @uid), 108) + ':' + CONVERT(VARCHAR(5), dbo.TZ_GetTime(SunEnd, DEFAULT, @uid), 108)
				WHEN 2 THEN CONVERT(VARCHAR(5), dbo.TZ_GetTime(MonStart, DEFAULT, @uid), 108) + ':' + CONVERT(VARCHAR(5), dbo.TZ_GetTime(MonEnd, DEFAULT, @uid), 108)
				WHEN 3 THEN CONVERT(VARCHAR(5), dbo.TZ_GetTime(TueStart, DEFAULT, @uid), 108) + ':' + CONVERT(VARCHAR(5), dbo.TZ_GetTime(TueEnd, DEFAULT, @uid), 108)
				WHEN 4 THEN CONVERT(VARCHAR(5), dbo.TZ_GetTime(WedStart, DEFAULT, @uid), 108) + ':' + CONVERT(VARCHAR(5), dbo.TZ_GetTime(WedEnd, DEFAULT, @uid), 108)
				WHEN 5 THEN CONVERT(VARCHAR(5), dbo.TZ_GetTime(ThuStart, DEFAULT, @uid), 108) + ':' + CONVERT(VARCHAR(5), dbo.TZ_GetTime(ThuEnd, DEFAULT, @uid), 108)
				WHEN 6 THEN CONVERT(VARCHAR(5), dbo.TZ_GetTime(FriStart, DEFAULT, @uid), 108) + ':' + CONVERT(VARCHAR(5), dbo.TZ_GetTime(FriEnd, DEFAULT, @uid), 108)
				WHEN 7 THEN CONVERT(VARCHAR(5), dbo.TZ_GetTime(SatStart, DEFAULT, @uid), 108) + ':' + CONVERT(VARCHAR(5), dbo.TZ_GetTime(SatEnd, DEFAULT, @uid), 108)
			END, 'N/A')
	FROM dbo.WorkingHours
	WHERE CustomerID = @cid
		
--	SELECT @result
	RETURN @result
END




GO
