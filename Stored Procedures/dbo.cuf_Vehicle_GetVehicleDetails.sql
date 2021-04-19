SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_GetVehicleDetails]
(
	@VehicleId UNIQUEIDENTIFIER,
	@uid uniqueidentifier = null,
	@date datetime = NULL
)
AS
	--declare @VehicleId uniqueidentifier,
	--		@uid uniqueidentifier,
	--		@date datetime;
	
	--set @VehicleId = '39C6BE26-6675-DF11-85AD-0015173D1551'
	--set @uid = 'F2399FB5-2DEA-498C-9773-7F6649615CC2'
	--set @date = null
	
	declare @sdate datetime,
			@edate datetime;
	
	set @sdate = DateAdd(hour, -1, @date)
	set @edate = DateAdd(hour, 1, @date)

	declare @speedmult float
	declare @timediff nvarchar(30)
	set @speedmult = cast(dbo.[UserPref](@uid,208) as float)
	set @timediff = dbo.[UserPref](@uid, 600)
	
	IF (@date IS NULL)
	BEGIN
		SELECT
			@VehicleId AS VehicleId,
			e.Lat,
			e.Long,
			dbo.[GetGeofenceNameFromLongLat] (e.Lat, e.Long, @uid, dbo.[GetAddressFromLongLat] (e.Lat, e.Long)) as ReverseGeoCode,
			--dbo.[GetAddressFromLongLat] (e.Lat, e.Long) as ReverseGeoCode,
			e.Heading AS Direction,
			cast(e.Speed * @speedmult as smallint) as Speed,
			dbo.[TZ_GetTime]( e.EventDateTime, @timediff, @uid) as EventDateTime,
			dbo.[TZ_GetTime]( GetUtcDate(), @timediff, @uid) as QueryTime,
			e.EventDateTime as GMTEventTime,
			dbo.GetDriverIdFromInt(e.DriverIntId) AS DriverId
		FROM [dbo].[Event] e
		WHERE e.VehicleIntId = dbo.GetVehicleIntFromId(@VehicleId)
		AND e.Archived = 0
		-- Not sure about this bit, but if I order by EventDateTime on Event it takes a stupid amount of time to run
		AND e.EventId = (SELECT EventId FROM [dbo].VehicleLatestEvent WHERE VehicleId = @Vehicleid)
	END
	ELSE
	BEGIN
		SELECT TOP 1
			@VehicleId AS VehicleId,
			e.Lat,
			e.Long,
			dbo.[GetGeofenceNameFromLongLat] (e.Lat, e.Long, @uid, dbo.[GetAddressFromLongLat] (e.Lat, e.Long)) as ReverseGeoCode,
			--dbo.[GetAddressFromLongLat] (e.Lat, e.Long) as ReverseGeoCode,
			e.Heading AS Direction,
			cast(e.Speed * @speedmult as smallint) as Speed,
			dbo.[TZ_GetTime]( e.EventDateTime, dbo.[UserPref](@uid, 600), @uid) as EventDateTime,
			dbo.[TZ_GetTime]( GetUtcDate(), @timediff, @uid) as QueryTime,
			e.EventDateTime as GMTEventTime,
			dbo.GetDriverIdFromInt(e.DriverIntId) AS DriverId
		FROM [dbo].[Event] e
		WHERE e.VehicleIntId = dbo.GetVehicleIntFromId(@VehicleId)
		AND e.Archived = 0
		AND e.EventDateTime between @sdate and @edate
		ORDER BY e.EventDateTime ASC
	END

GO
