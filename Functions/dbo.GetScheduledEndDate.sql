SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetScheduledEndDate] 
(
	@periodtypeid INT,
	@uid UNIQUEIDENTIFIER
)
RETURNS DATETIME
AS
BEGIN

	--DECLARE @periodtypeid INT,
	--		@uid UNIQUEIDENTIFIER
	
	--SET @periodtypeid = 19
	--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

	DECLARE @result DATETIME,
			@now DATETIME,
			@cid UNIQUEIDENTIFIER,
			@financialday SMALLINT,
			@financialmonth SMALLINT
						
	SET @now = dbo.TZ_GetTime(GETUTCDATE(), DEFAULT, @uid)
	SELECT @cid = CustomerID FROM dbo.[User] WHERE UserID = @uid
	SET @financialday = ISNULL(dbo.CustomerPref(@cid, 3011), 1) -- Set customer financial day using default 1
	SET @financialmonth = ISNULL(dbo.CustomerPref(@cid, 3012), 1) -- Set customer financial day using default January

	SELECT @result =
	CASE @periodtypeid 
		WHEN 1 THEN @now
		WHEN 2 THEN DATEADD(ss, -1, CAST(FLOOR(CAST(@now AS FLOAT)) AS DATETIME))
		WHEN 3 THEN DATEADD(ss, -1, CAST(FLOOR(CAST(@now AS FLOAT)) AS DATETIME))
		WHEN 4 THEN DATEADD(ss, -1, DATEADD(wk, DATEDIFF(wk,0,@now), 0))
		WHEN 5 THEN DATEADD(ss, -1, CAST(FLOOR(CAST(@now AS FLOAT)) AS DATETIME))
		WHEN 6 THEN DATEADD(ss, -1, CAST(CAST(YEAR(@now) AS CHAR(4)) + '-' + RIGHT('0' + CAST(MONTH(@now) AS CHAR(2)) ,2) + '-01 00:00' AS DATETIME))
		WHEN 7 THEN DATEADD(ss, -1, CAST(FLOOR(CAST(@now AS FLOAT)) AS DATETIME))
		WHEN 8 THEN DATEADD(ss, -1, CAST(FLOOR(CAST(@now AS FLOAT)) AS DATETIME))
		WHEN 9 THEN DATEADD(ss, -1, CAST(FLOOR(CAST(@now AS FLOAT)) AS DATETIME))
		WHEN 10 THEN DATEADD(ss, -1, CAST(FLOOR(CAST(@now AS FLOAT)) AS DATETIME))
		WHEN 11 THEN DATEADD(ss, -1, CAST(FLOOR(CAST(@now AS FLOAT)) AS DATETIME))
		WHEN 12 THEN DATEADD(ss, -1, CAST(FLOOR(CAST(@now AS FLOAT)) AS DATETIME))
		WHEN 13 THEN DATEADD(ss, -1, CAST(FLOOR(CAST(@now AS FLOAT)) AS DATETIME))
		WHEN 14 THEN DATEADD(dd, (DATEPART(dw,@now)-2) * -1, DATEADD(ss, -1, CAST(FLOOR(CAST(@now AS FLOAT)) AS DATETIME)))
		WHEN 16 THEN DATEADD(ss, -1, CAST(FLOOR(CAST(@now AS FLOAT)) AS DATETIME))
		WHEN 18 THEN DATEADD(DAY, -1, CASE WHEN DATEPART(DAY, @now) < @financialday THEN DATEADD(ss, -1, DATEADD(MONTH, -1, CAST(CAST(YEAR(@now) AS CHAR(4)) + '-' + RIGHT('0' + CAST(MONTH(@now) AS CHAR(2)) ,2) + '-' + CAST(@financialday + 1 AS CHAR(2)) + ' 00:00' AS DATETIME))) ELSE DATEADD(ss, -1, CAST(CAST(YEAR(@now) AS CHAR(4)) + '-' + RIGHT('0' + CAST(MONTH(@now) AS CHAR(2)) ,2) + '-' + CAST(@financialday + 1 AS CHAR(2)) + ' 00:00' AS DATETIME)) END)
		WHEN 17 THEN DATEADD(ss, -1, CAST(FLOOR(CAST(@now AS FLOAT)) AS DATETIME))
		WHEN 19 THEN DATEADD(DAY, -1, CASE WHEN DATEPART(MONTH, @now) < @financialmonth OR (DATEPART(MONTH, @now) = @financialmonth AND DATEPART(DAY, @now) < @financialday) THEN DATEADD(ss, -1, DATEADD(YEAR, -1, CAST(CAST(YEAR(@now) AS CHAR(4)) + '-' + RIGHT('0' + CAST(@financialmonth AS CHAR(2)) ,2) + '-' + CAST(@financialday + 1 AS CHAR(2)) + ' 00:00' AS DATETIME))) ELSE DATEADD(ss, -1, CAST(CAST(YEAR(@now) AS CHAR(4)) + '-' + RIGHT('0' + CAST(@financialmonth AS CHAR(2)) ,2) + '-' + CAST(@financialday + 1 AS CHAR(2)) + ' 00:00' AS DATETIME)) END)
	END
	
	SELECT @result = dbo.TZ_ToUtc(@result, DEFAULT, @uid)

	--SELECT @Result	
	RETURN @result
END

GO
