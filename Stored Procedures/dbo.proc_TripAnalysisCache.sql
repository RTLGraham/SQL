SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Stored Procedure

CREATE PROCEDURE [dbo].[proc_TripAnalysisCache]
(
	@RequestId INT
)
AS

SET NOCOUNT ON

DECLARE @customerintid INT
DECLARE @sdate datetime
DECLARE @edate datetime
DECLARE @reportparameter1 int
DECLARE @moving int
DECLARE @stopped int
DECLARE @groupid UNIQUEIDENTIFIER

-- Get parameters from TripAnalysisRequest table
SELECT	@sdate = StartDate,
		@edate = EndDate,
		@groupid = GeofenceGroupID,
		@customerintid = dbo.GetCustomerIntFromId(u.CustomerID)
FROM dbo.TripAnalysisRequest tar
INNER JOIN dbo.[User] u ON tar.UserID = u.UserID
WHERE tar.TripAnalysisRequestID = @RequestId

--SET @gname = 'BP Trip Analysis' -- Geofence Group Name
--
--SELECT @customerintid = CustomerIntId from dbo.Customer where Name = 'BP'
--SET @sdate = '2012-09-01 00:00:00.000'
--SET @edate = '2012-09-30 23:59:00.000'

SET @reportparameter1 = 2

IF @reportparameter1 = 1 -- Key On/Off
BEGIN
	SET @moving = 4
	SET @stopped = 5
END
IF @reportparameter1 = 2 -- Moving/Stopped
BEGIN
	SET @moving = 1
	SET @stopped = 0
END

-- Delete any previous cached data
Delete from TripsAndStops_RouteAnalysis Where CustomerIntID = @customerintid and Timestamp >= @sdate and TimeStamp <= @edate
Insert into TripsAndStops_RouteAnalysis
Select ts.*, NULL from TripsAndStops ts
Where ts.CustomerIntID = @customerintid and ts.Timestamp >= @sdate and ts.TimeStamp <= @edate and ts.VehicleState in (@moving,@stopped)


DECLARE @lat float
DECLARE @long float
DECLARE @gid uniqueidentifier

DECLARE elim CURSOR FAST_FORWARD READ_ONLY FOR
Select distinct Round(latitude,3),Round(longitude,3)
from TripsAndStops_RouteAnalysis Where CustomerIntID = @customerintid and Timestamp >= @sdate and TimeStamp <= @edate and VehicleState in (@moving,@stopped) and GeofenceID is null
OPEN elim
FETCH NEXT FROM elim into @lat,@long
WHILE @@FETCH_STATUS = 0
BEGIN

	SELECT TOP 1 @gid = g.GeofenceId
	FROM dbo.Geofence g
	INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = g.GeofenceId
	INNER JOIN dbo.[Group] gr ON gr.GroupId = gd.GroupId AND gr.GroupTypeId = 4 AND gr.IsParameter = 0 AND gr.Archived = 0
	WHERE gr.GroupId = @groupid 
	  AND dbo.DistanceBetweenPoints(@lat, @long, CenterLat, CenterLon) <= 0.35 --distance in km
	  AND g.Archived = 0
	ORDER BY dbo.DistanceBetweenPoints(@lat, @long, CenterLat, CenterLon)

    If @gid is not null
    BEGIN
		Update TripsAndStops_RouteAnalysis Set GeofenceID = @gid Where @lat = Round(latitude,3) and @long = Round(longitude,3) and CustomerIntID = @customerintid and Timestamp >= @sdate and TimeStamp <= @edate and VehicleState in (@moving,@stopped)
    END
    SET @gid = null
	FETCH NEXT FROM elim into @lat,@long
END
CLOSE elim
DEALLOCATE elim





GO
