SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_ActivityEventsByDriver_Bert]
(
	@did UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN

	--DECLARE @did UNIQUEIDENTIFIER,
	--		@sdate DATETIME,
	--		@edate DATETIME,
	--		@uid UNIQUEIDENTIFIER

	--SET @did = N'B3555DF9-52D5-4E8E-ACEA-A4A0CBAC0D77'
	--SET @sdate = '2019-07-01 00:00'
	--SET @edate = '2019-07-09 23:59'
	--SET @uid = N'0B9C8586-FB6B-464D-B135-5329F47E5BA2'

	SELECT x.DriverIntId,
		   x.CreationCodeId,
		   x.EventDateTime
	FROM (
			SELECT	e.DriverIntId, 
					CAST(FLOOR(CAST(e.EventDateTime AS FLOAT)) AS DATETIME) AS DayId,
					e.CreationCodeId,
					dbo.TZ_GetTime(e.EventDateTime,DEFAULT,@uid) AS EventDateTime, 
					ROW_NUMBER() OVER(PARTITION BY FLOOR(CAST(e.EventDateTime AS FLOAT)), e.CreationCodeId ORDER BY e.EventDateTime) AS RowNum
			FROM dbo.Event e
			INNER JOIN dbo.Driver d ON d.DriverIntId = e.DriverIntId
			WHERE d.DriverId = @did
			  AND e.EventDateTime BETWEEN @sdate AND @edate
			  AND e.CreationCodeId BETWEEN 220 AND 226
		) x WHERE x.RowNum = 1

END	


GO
