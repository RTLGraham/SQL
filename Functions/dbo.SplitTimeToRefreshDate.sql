SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dmitrijs Jurins>
-- Create date: <2011-04-13>
-- Description:	<Devides the datetime interval into gaps>
-- =============================================
CREATE FUNCTION [dbo].[SplitTimeToRefreshDate]
(	
	@sdate DATETIME,
	@edate DATETIME
)
RETURNS @results TABLE ( ReportType NVARCHAR(2), RefreshDate DATETIME )
AS
BEGIN 

	IF DateDiff(second,@sdate,@edate) = 7 * 24 * 3600
	BEGIN
		INSERT INTO @results ( ReportType, RefreshDate ) VALUES ('7D', dateadd(day,1,@edate))
	END
	ELSE IF DateDiff(second,@sdate,@edate) = 28 * 24 * 3600
	BEGIN
		INSERT INTO @results ( ReportType, RefreshDate ) VALUES ('4W', dateadd(day,7,@edate))
	END
	ELSE IF DateDiff(second,@sdate,@edate) >= 84 * 24 * 3600 and DateDiff(second,@sdate,@edate) <= 93 * 24 * 3600
	BEGIN
		INSERT INTO @results ( ReportType, RefreshDate ) VALUES ('3M', dateadd(month,1,@edate))
	END
	ELSE IF DateDiff(second,@sdate,@edate) >= 168 * 24 * 3600 and DateDiff(second,@sdate,@edate) <= 186 * 24 * 3600
	BEGIN
		INSERT INTO @results ( ReportType, RefreshDate ) VALUES ('6M',dateadd(month,1,@edate))
	END
	ELSE IF DateDiff(second,@sdate,@edate) >= 336 * 24 * 3600 and DateDiff(second,@sdate,@edate) <= 372 * 24 * 3600
	BEGIN
		INSERT INTO @results ( ReportType, RefreshDate ) VALUES ('1Y',dateadd(month,1,@edate))
	END
	ELSE
	BEGIN
		INSERT INTO @results ( ReportType, RefreshDate ) VALUES ('',getutcdate())
	END
	
	RETURN
END

GO
