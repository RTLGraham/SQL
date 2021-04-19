SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dmitrijs Jurins>
-- Create date: <2011-04-13>
-- Description:	<Devides the datetime interval into gaps>
-- =============================================
CREATE FUNCTION [dbo].[SplitTimeToIntervals]
(	
	@sdate DATETIME,
	@edate DATETIME
)
RETURNS @results TABLE ( RowCnt INT, Gap INT )
AS
BEGIN 

	IF (DATEDIFF(DAY,@sdate,@edate) <= 28)
	BEGIN
		INSERT INTO @results (RowCnt, Gap) VALUES (DATEDIFF(DAY,@sdate,@edate), 1)
	END
	ELSE IF DATEDIFF(week,@sdate,@edate) = 13
	BEGIN
		SET @sdate = DATEADD(MONTH,-3,@edate)
		INSERT INTO @results (RowCnt, Gap) VALUES (DATEDIFF(week,@sdate,@edate), 2)
	END
	ELSE IF DATEDIFF(week,@sdate,@edate) >= 25 and DATEDIFF(week,@sdate,@edate) <= 28
	BEGIN
		INSERT INTO @results (RowCnt, Gap) VALUES (DATEDIFF(week,@sdate,@edate), 2)
	END
	ELSE IF DATEDIFF(week,@sdate,@edate) >= 52
	BEGIN
		INSERT INTO @results (RowCnt, Gap) VALUES (DATEDIFF(week,@sdate,@edate), 2)
	END
	ELSE
	BEGIN
		INSERT INTO @results (RowCnt, Gap) VALUES (DATEDIFF(DAY,@sdate,@edate), 1)
	END
	
	RETURN
END

GO
