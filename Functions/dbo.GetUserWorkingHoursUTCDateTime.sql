SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetUserWorkingHoursUTCDateTime] 
(
	@UserStartDateTime DATETIME,
	@UserDateTime DATETIME,
	@uid UNIQUEIDENTIFIER
)
RETURNS DATETIME
AS
BEGIN
--	DECLARE @UserStartDateTime DATETIME,
--			@UserDateTime DATETIME,
--			@uid UNIQUEIDENTIFIER
--			
--	SET @UserStartDateTime = '2014-05-30 06:00'	
--	SET @UserDateTime = '2014-05-30 18:00'
--	SET @uid = N'5BE41794-E1D5-442C-AE07-3B1760BA2D84'
	
	DECLARE @result DATETIME
	
	SELECT @result =
	CAST(CONVERT(VARCHAR(10), DATEADD(dd, DATEDIFF(dd, @UserStartDateTime, '1900-01-01'), @UserDateTime), 120) + ' ' + CONVERT(VARCHAR(5), dbo.TZ_ToUtcNoDaylightSavings(@UserDateTime, DEFAULT, @uid), 108) AS DATETIME)
	
	-- If we have shifted to another utc date add one day to the result
	IF DATEPART(dd, dbo.TZ_ToUtcNoDaylightSavings(@UserStartDateTime, DEFAULT, @uid)) != DATEPART(dd, dbo.TZ_ToUtcNoDaylightSavings(@UserDateTime, DEFAULT, @uid))
		SELECT @result = DATEADD(dd, 1, @result)
		
--	SELECT @result
	RETURN @result
END



GO
