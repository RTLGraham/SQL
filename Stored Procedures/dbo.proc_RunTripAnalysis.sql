SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_RunTripAnalysis]
(
	@RequestId INT
)
AS

--DECLARE @RequestId INT
--SET @RequestId = 2

DECLARE @sdate datetime
DECLARE @edate datetime
DECLARE @reportparameter1 int
DECLARE @moving int
DECLARE @stopped int
DECLARE @diststr varchar(20)
DECLARE @distmult float 
DECLARE @create bit
DECLARE @depname varchar(30)
DECLARE @gap FLOAT
DECLARE @breakmin FLOAT
DECLARE @depid INT
DECLARE @groupid UNIQUEIDENTIFIER
DECLARE @siteid VARCHAR(MAX)

-- Get parameters from TripAnalysisRequest table
SELECT	@sdate = StartDate,
		@edate = EndDate,
		@groupid = VehicleGroupID,
		@siteid = geo.Name
FROM dbo.TripAnalysisRequest tar
INNER JOIN dbo.Geofence geo ON geo.GeofenceId = tar.BaseGeofenceID
WHERE tar.TripAnalysisRequestID = @RequestId

-- Mark request as 'In Progress'
UPDATE dbo.TripAnalysisRequest
SET Status = 0
WHERE TripAnalysisRequestID = @RequestId

--SET @sdate = '2013-01-01 00:00:00.000'
--SET @edate = '2013-01-31 23:59:00.000'
--SET @groupid = 'Grangemouth' -- Vehicle group for which to report
--SET @siteid = '01 TP GRT Terminal' -- Set siteid from which round trips will be determined

SET @gap = 12 -- Stop time duration for recording a 'real' stop (breaks are a minimum of 15mins)
SET @breakmin = 15 -- Exclude stops longer than this from the trip time

SET @reportparameter1 = 2
IF @reportparameter1 = 1
BEGIN
	SET @moving = 4
	SET @stopped = 5
END
IF @reportparameter1 = 2
BEGIN
	SET @moving = 1
	SET @stopped = 0
END

set @create = 1

DECLARE @lat float
DECLARE @long float
DECLARE @gid UNIQUEIDENTIFIER

create table #RouteAnalysis (Registration varchar(50),StartDest varchar(max),StartLocation varchar(max), EndDest varchar(max),EndLocation varchar(max),StopTimeMin float, TripTimeMin float,TripDistanceKM float,StartTime smalldatetime,EndTime smalldatetime, StartID bigint,EndID bigint)

Insert into #RouteAnalysis
Select distinct v.registration,g1.description,Upper(g1.name),g2.description,Upper(g2.name),cast(r1.duration as float)/60,cast(r2.duration as float)/60,cast(r2.tripdistance as float) / 10 , r1.timestamp, r2.Timestamp,r1.tripsandstopsid,r2.tripsandstopsid
from tripsandstops_routeanalysis r1
left join dbo.geofence g1 on g1.geofenceid = r1.geofenceid
inner join tripsandstops_routeanalysis r2 on r1.tripsandstopsid = r2.previousid and r1.vehicleintid = r2.vehicleintid
left join dbo.geofence g2 on g2.geofenceid = r2.geofenceid
inner join vehicle v on r1.vehicleintid= v.vehicleintid
INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
where r1.vehiclestate = @moving and r2.vehiclestate = @stopped
  and r1.CustomerIntID = r2.CustomerIntID and r1.timestamp >= @sdate and r2.timestamp <= @edate
  AND g.GroupTypeId = 1
  AND g.Archived = 0
  AND g.IsParameter = 0
  AND g.GroupId = @groupid
order by r1.tripsandstopsid

delete from #RouteAnalysis where tripdistanceKM < 1 and startlocation is null and endlocation is null
delete from #RouteAnalysis where tripdistanceKM < 1 and startlocation = endlocation

Declare @reg varchar(50)
DECLARE @startid BIGINT
Declare @start varchar(50)
Declare @startdest varchar(20)
DECLARE @endid BIGINT
Declare @end varchar(50)
Declare @enddest varchar(20)
declare @sitetime float
declare @triptime float
declare @tripdistance float
declare @st smalldatetime
declare @et smalldatetime
Declare @creg varchar(50)
DECLARE @cstartid BIGINT
Declare @cstart varchar(50)
Declare @cstartdest varchar(20)
DECLARE @cendid BIGINT
Declare @cend varchar(50)
Declare @cenddest varchar(20)
declare @cttm float
declare @cstm float
declare @ctdm float
declare @cst smalldatetime
declare @cet SMALLDATETIME
DECLARE @break FLOAT

set @reg = NULL
SET @startid = NULL
set @start = NULL
set @startdest = NULL
SET @endid = NULL
set @end = NULL
set @enddest = NULL
set @sitetime = 0
set @triptime = 0
set @tripdistance = 0
set @st = NULL
set @et = NULL
SET @break = 0

CREATE TABLE #RouteAnalysisTrips (Registration varchar(50), StartId BIGINT, StartDest varchar(20), StartLocation varchar(50), EndId BIGINT, EndDest varchar(20), EndLocation varchar(50), TripStart datetime, TripEnd datetime, SiteTime float, TripTime float, TripDistance FLOAT, Breaks FLOAT)
CREATE NONCLUSTERED INDEX [IX_Routeanalysistrips] ON #RouteAnalysisTrips 
(
	Registration ASC,
	StartDest ASC,
	EndDest ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]

declare RACursor Cursor Fast_Forward Read_Only for 
select Registration,StartId,StartDest,StartLocation,EndId,EndDest,EndLocation,TripTimeMin,TripDistanceKM,StopTimeMin,starttime,endtime
from #RouteAnalysis order by registration,starttime,endtime
Open RACursor
Fetch Next From RACursor into @creg,@cstartid,@cstartdest,@cstart,@cendid,@cenddest,@cend,@cttm,@ctdm,@cstm,@cst,@cet
-- Initialise first row of data
set @reg = @creg
SET @startid = @cstartid
set @start = @cstart
set @startdest = @cstartdest
SET @endid = @cendid
set @end = @cend
set @enddest = @cenddest
SET @triptime = @cttm
SET @tripdistance = @ctdm
SET @sitetime = @cstm
set @st = @cst
set @et = @cet
While @@FETCH_STATUS = 0
BEGIN
	Fetch Next From RACursor into @creg,@cstartid,@cstartdest,@cstart,@cendid,@cenddest,@cend,@cttm,@ctdm,@cstm,@cst,@cet
	IF	(@creg <> @reg) -- new vehicle
	 OR	(@cstart <> @end) -- starting from a new site
	 OR (@end is not NULL AND @sitetime > @gap) -- we have finished at a known location for a long enough duration to record as a customer site stop
		BEGIN
			-- write the currently accumulated row
			insert into #routeanalysistrips (Registration, StartId, StartDest,StartLocation, EndId, EndDest, EndLocation, TripStart, TripEnd, SiteTime, TripTime, TripDistance, Breaks)
			values (@reg,@startid,@startdest,@start,@endid,@enddest,@end,@st,@et,@sitetime,@triptime,@tripdistance,@break)
			-- initialise values for next vehicle
			set @reg = @creg
			SET @startid = @cstartid
			set @start = @cstart
			set @startdest = @cstartdest
			SET @endid = @cendid	
			set @end = @cend
			set @enddest = @cenddest
			SET @triptime = @cttm 
			SET @tripdistance = @ctdm
			SET @sitetime = @cstm
			set @st = @cst
			set @et = @cet
			SET @break = 0
		END 
	ELSE
		BEGIN
			IF @end is not NULL AND @cstm > @sitetime
			BEGIN
				SET @triptime = @triptime + @cttm
				SET @sitetime = @cstm
			END ELSE
			BEGIN
				IF @cstm > @breakmin
				BEGIN	
					SET @break = @break + @cstm -- accumulate the break time
					SET @triptime = @triptime + @cttm
				END ELSE
					SET @triptime = @triptime + @cttm + @cstm -- add stop time to trip time as it isn't a real break					
			END
			SET @tripdistance = @tripdistance + @ctdm
			-- Move to next end location
			SET @endid = @cendid	
			SET @end = @cend
			SET @enddest = @cenddest
			SET @et = @cet
		END	
END
Close RACursor
Deallocate RACursor

drop table #RouteAnalysis
        
--SELECT *
--FROM #RouteAnalysisTrips
        
-- Do a summary select
INSERT INTO dbo.TripAnalysisSummary
        ( TripAnalysisRequestId ,
          StartId ,
          StartLocation ,
          StartDescription ,
          EndId ,
          EndLocation ,
          EndDescription ,
          MinDurationMins ,
          MaxDurationMins ,
          AvgDurationMins ,
          TripCount ,
          MinDistance ,
          MaxDistance ,
          AvgDistance
        )
SELECT	@RequestId,
		NULL ,
        StartDest ,
        StartLocation,
        NULL ,
        EndDest	 ,
        EndLocation,
        [Min Duration (mins)] ,
        [Max Duration (mins)] ,
        [Avg Duration (mins)] ,
        [No of Trips] ,
        [Min Distance (km)] ,
        [Max Distance (km)] ,
        [Avg Distance (km)] FROM
(SELECT	t1.StartDest, 
		t1.StartLocation,
		t1.EndDest,
		t1.EndLocation,
		Round(min(t1.TripTime + t2.TripTime + t2.SiteTime),0) as [Min Duration (mins)],
		Round(max(t1.TripTime + t2.TripTime + t2.SiteTime),0) as [Max Duration (mins)],
		Round(avg(t1.TripTime + t2.TripTime + t2.SiteTime),0) as [Avg Duration (mins)],
		count(*) as [No of Trips],
		Round(min(t1.TripDistance + t2.TripDistance),0) as [Min Distance (km)], 
		Round(max(t1.TripDistance + t2.TripDistance),0) as [Max Distance (km)], 
		Round(avg(t1.TripDistance + t2.TripDistance),0) as [Avg Distance (km)]
FROM (SELECT *, ROW_NUMBER() OVER (ORDER BY Registration, TripStart) AS 'RowNumber' FROM #routeanalysistrips) t1
INNER JOIN (SELECT *, ROW_NUMBER() OVER (ORDER BY Registration, TripStart) AS 'RowNumber' FROM #routeanalysistrips) t2 ON t1.Registration = t2.Registration AND t1.EndLocation = t2.StartLocation AND t2.EndLocation = t1.StartLocation AND t2.Rownumber = t1.RowNumber + 1
GROUP BY t1.StartDest, t1.StartLocation, t1.EndDest, t1.EndLocation
) result
WHERE result.StartDest = @siteid
ORDER BY result.EndLocation
   
-- Now do a round trips select!
INSERT INTO dbo.TripAnalysisDetail
        ( TripAnalysisRequestId ,
          TripAnalysisSummaryId ,
          StartId ,
          StartLocation ,
          StartDescription ,
          EndId ,
          EndLocation ,
          EndDescription ,
          DepartSite ,
          ArriveCustomer ,
          Registration ,
          OutwardDistance ,
          OutwardTimeMins ,
          OutwardBreakMins ,
          UnloadTimeMins ,
          DepartCustomer ,
          ArriveSite ,
          InwardDistance ,
          InwardTimeMins ,
          InwardBreakMins
        )
SELECT  @RequestId,
		0,
		StartId,
		StartDest,
		StartLocation,
		EndId,
		EndDest,
		EndLocation,
		[Depart Site] ,
        [Arrive Customer] ,
        Registration,
        [Outward Distance] ,
        [Outward Time] ,
        [Breaks en-route] ,
        [Unload Time] ,
        [Depart Customer] ,
        [Arrive Site] ,
        [Inward Distance] ,
        [Inward Time] ,
        [Breaks Inward en-route] FROM
(SELECT	t1.StartId, 
		t1.StartDest,
		t1.StartLocation, 
		t1.EndId, 
		t1.EndDest,
		t1.EndLocation,
--		t1.SiteTime AS 'Loading Time?',
		t1.TripStart AS 'Depart Site',
		t1.TripEnd AS 'Arrive Customer',
		t1.Registration,
		ROUND(t1.TripDistance,0) AS 'Outward Distance',
		ROUND(t1.TripTime,0) AS 'Outward Time',
		ROUND(t1.Breaks, 0) AS 'Breaks en-route',
		ROUND(t2.SiteTime,0) AS 'Unload Time',
		t2.TripStart AS 'Depart Customer',
		t2.TripEnd AS 'Arrive Site',
		ROUND(t2.TripDistance,0) AS 'Inward Distance',
		ROUND(t2.TripTime,0) AS 'Inward Time',
		ROUND(t2.Breaks,0) AS 'Breaks Inward en-route'
FROM (SELECT *, ROW_NUMBER() OVER (ORDER BY Registration, TripStart) AS 'RowNumber' FROM #routeanalysistrips) t1
INNER JOIN (SELECT *, ROW_NUMBER() OVER (ORDER BY Registration, TripStart) AS 'RowNumber' FROM #routeanalysistrips) t2 ON t1.Registration = t2.Registration AND t1.EndLocation = t2.StartLocation AND t2.EndLocation = t1.StartLocation AND t2.Rownumber = t1.RowNumber + 1
) result
WHERE result.StartDest = @siteid
ORDER BY result.EndLocation, [Depart Site]   
        
-- Do an individual legs select
INSERT INTO dbo.TripAnalysisLeg
        ( TripAnalysisRequestId ,
          StartId ,
          StartLocation ,
          StartDescription ,
          SiteTime ,
          EndId ,
          EndLocation ,
          EndDescription ,
          TripStart ,
          TripEnd ,
          Registration ,
          TripDistance ,
          TripTimeMins ,
          BreakMins 
        )
SELECT	@RequestId,
		StartId, 
		StartDest, 
		StartLocation,
		ROUND(SiteTime,0),
		EndId, 
		EndDest,
		EndLocation,
		TripStart,
		TripEnd,
		Registration,
		ROUND(TripDistance,0),
		ROUND(TripTime,0),
		ROUND(Breaks,0)
FROM #routeanalysistrips
WHERE startDest is not NULL
  AND EndDest is not NULL
ORDER BY Registration, Tripstart

DROP TABLE #routeanalysistrips

-- Complete the trip Request
UPDATE dbo.TripAnalysisRequest
SET Status = 1,
CompletionDate = GETDATE(),
LastOperation = GETDATE()
WHERE TripAnalysisRequestID = @RequestId

GO
