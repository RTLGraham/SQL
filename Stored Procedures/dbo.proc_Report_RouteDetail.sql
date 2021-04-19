SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_RouteDetail]
(
	@rids varchar(max), 
	@vids NVARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE @rids varchar(max),
--		@vids NVARCHAR(MAX),
--		@sdate datetime,
--		@edate datetime,
--		@uid UNIQUEIDENTIFIER
--SET @rids = '175,176'
--SET @sdate = '2014-10-10 00:00'
--SET @edate = '2014-10-10 23:59'
--SET @uid = N'F9A00148-7520-461B-B650-7514B026B373'

-- Determine period sizes based upon provided start date and end date total duration -- use dates in user time zone

DECLARE @period_dates TABLE (
		PeriodNum TINYINT IDENTITY (1,1),
		StartDate DATETIME,
		EndDate DATETIME,
		PeriodType VARCHAR(MAX))
      
INSERT  INTO @period_dates ( StartDate, EndDate, PeriodType )
        SELECT  StartDate,
                EndDate,
                PeriodType
        FROM    dbo.CreateDependentDateRange(@sdate, @edate, @uid, 1, 1, 6)

-- Convert dates to UTC
SET @sdate = [dbo].TZ_ToUTC(@sdate,default,@uid)
SET @edate = [dbo].TZ_ToUTC(@edate,default,@uid)

SELECT	r.RouteID,
		r.RouteName, 
		dbo.TZ_GetTime(p.StartDate, DEFAULT, @uid) AS StartDate,
		dbo.TZ_GetTime(p.EndDate, DEFAULT, @uid) AS EndDate,
		COUNT(pa.PassengerAnalysisId) AS TotalTrips,
		SUM(pa.RoutePassengers) AS TotalPassengers 
FROM dbo.PassengerAnalysis pa
INNER JOIN dbo.Vehicle v ON pa.VehicleId = v.VehicleId
INNER JOIN dbo.Route r ON pa.RouteId = r.RouteID
INNER JOIN @period_dates p ON pa.RouteStartDateTime BETWEEN p.StartDate AND p.EndDate
WHERE pa.RouteStartDateTime BETWEEN @sdate AND @edate
  AND r.RouteID IN (SELECT VALUE FROM dbo.Split(@rids, ','))
  AND v.VehicleID IN (SELECT VALUE FROM dbo.Split(@vids, ','))
GROUP BY r.RouteID, r.RouteName, p.StartDate, p.EndDate




GO
