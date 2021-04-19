SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_SiteVisits]
(
	@geoids NVARCHAR(MAX),
	@sdate DATETIME,
	@edate DATETIME,
	@uid UNIQUEIDENTIFIER
)
AS	
BEGIN

	--DECLARE @geoids NVARCHAR(MAX),
	--		@sdate DATETIME,
	--		@edate DATETIME,
	--		@uid UNIQUEIDENTIFIER

	--SET @geoids = N'706D74EA-B107-4679-97C0-D079A771BB93,387A3805-23A3-4BC3-AD0F-D88D7A9450FB,99096DE4-9FA2-45EF-AB3C-8F6A766FE632,E73DC854-6843-4ADA-AA53-ECBBD47D0D4B,211F4463-96E6-4874-9143-C4A2441DB9CE,2C055088-88FF-4C49-948B-0B4C2E6D486E,C5B5AD74-07F4-4955-B538-97D5A3E21293,BB1FDEAC-EFB8-42A4-B8ED-059B44455D19,5F9E03F4-7DBA-410C-9496-8EEE9AEBD4CE,4AD7B04A-966A-4980-B23A-C9BD5F53A101,252310A4-3876-4AD5-8FC6-1187B8FF1FCB,6308AA9C-8389-4D1C-9E79-814050053E58';
	--SET @sdate = '2018-01-10 00:00';
	--SET @edate = '2018-01-18 23:59';
	--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5';

	DECLARE @tempmult FLOAT,
			@liquidmult FLOAT,
			@tempunit NVARCHAR(5)

	SET @tempmult = CAST(ISNULL(dbo.[UserPref](@uid, 214),1) AS FLOAT)
	SET @liquidmult = CAST(ISNULL(dbo.[UserPref](@uid, 200),1) AS FLOAT)
	SET @tempunit = ISNULL(dbo.UserPref(@uid, 215),'°C');

	WITH Visits_CTE (SiteId, VehicleIntId, DriverIntId, VisitId, CreationCodeId, MinEventId, MinTime, MaxEventId, MaxTime, Hits)
	AS	
		(SELECT vgh.GeofenceId, vgh.VehicleIntId, vgh.EntryDriverIntId, vgh.VehicleGeofenceHistoryId, e.CreationCodeId, 
					MIN(e.EventId) OVER(PARTITION BY vgh.GeofenceId, vgh.VehicleIntId, vgh.VehicleGeofenceHistoryId, e.CreationCodeId) AS MinEvent, 
					MIN(e.EventDateTime) OVER(PARTITION BY vgh.GeofenceId, vgh.VehicleIntId, vgh.VehicleGeofenceHistoryId, e.CreationCodeId) AS MinTime, 
					MAX(e.EventId) OVER(PARTITION BY vgh.GeofenceId, vgh.VehicleIntId, vgh.VehicleGeofenceHistoryId, e.CreationCodeId) AS MaxEvent, 
					MAX(e.EventDateTime) OVER(PARTITION BY vgh.GeofenceId, vgh.VehicleIntId, vgh.VehicleGeofenceHistoryId, e.CreationCodeId) AS MaxTime,
					COUNT(vgh.GeofenceId) OVER(PARTITION BY e.VehicleIntId, e.EventId) AS Hits
		FROM dbo.VehicleGeofenceHistory vgh
			INNER JOIN dbo.Event e WITH (NOLOCK) ON e.VehicleIntId = vgh.VehicleIntId AND e.EventId BETWEEN vgh.EntryEventId AND vgh.ExitEventId AND e.CreationCodeId IN (88, 87)
		WHERE vgh.GeofenceId IN (SELECT Value FROM dbo.Split(@geoids, ','))
		  AND vgh.EntryDateTime BETWEEN @sdate AND @edate)

	--SELECT *
	--FROM Visits_CTE

	SELECT	geo.GeofenceId,
			geo.Name AS SiteName,
			geo.SiteId,
			v.VehicleId,
			v.Registration,
			v.VehicleTypeID,
			d.DriverId,
			dbo.FormatDriverNameByUser(d.DriverId, @uid) AS DriverName,
			dbo.TZ_GetTime(stops.EngOff, DEFAULT, @uid) AS VisitStart,
			dbo.TZ_GetTime(stops.EngOn, DEFAULT, @uid) AS VisitStop,
			DATEDIFF(SECOND, stops.EngOff, stops.EngOn) AS VisitDuration,
			dbo.GetScaleConvertAnalogValue(eoff.AnalogData0,0,v.VehicleId,@tempmult, @liquidmult) AS StartTemp0,
			dbo.GetScaleConvertAnalogValue(eon.AnalogData0,0,v.VehicleId,@tempmult, @liquidmult) AS StopTemp0,
			dbo.GetScaleConvertAnalogValue(eon.AnalogData0 - eoff.AnalogData0,0,v.VehicleId,@tempmult, @liquidmult) AS DeltaAnalogData0,
			dbo.GetScaleConvertAnalogValue(eoff.AnalogData1,1,v.VehicleId,@tempmult, @liquidmult) AS StartTemp1,
			dbo.GetScaleConvertAnalogValue(eon.AnalogData1,1,v.VehicleId,@tempmult, @liquidmult) AS StopTemp1,
			dbo.GetScaleConvertAnalogValue(eon.AnalogData1 - eoff.AnalogData1,1,v.VehicleId,@tempmult, @liquidmult) AS DeltaAnalogData1,
			dbo.GetScaleConvertAnalogValue(eoff.AnalogData2,2,v.VehicleId,@tempmult, @liquidmult) AS StartTemp2,
			dbo.GetScaleConvertAnalogValue(eon.AnalogData2,2,v.VehicleId,@tempmult, @liquidmult) AS StopTemp2,
			dbo.GetScaleConvertAnalogValue(eon.AnalogData2 - eoff.AnalogData2,2,v.VehicleId,@tempmult, @liquidmult) AS DeltaAnalogData2,
			dbo.GetScaleConvertAnalogValue(eoff.AnalogData3,3,v.VehicleId,@tempmult, @liquidmult) AS StartTemp3,
			dbo.GetScaleConvertAnalogValue(eon.AnalogData3,3,v.VehicleId,@tempmult, @liquidmult) AS StopTemp3,
			dbo.GetScaleConvertAnalogValue(eon.AnalogData3 - eoff.AnalogData3,3,v.VehicleId,@tempmult, @liquidmult) AS DeltaAnalogData3,
			CASE 
				WHEN dbo.GetScaleConvertAnalogValue(eoff.AnalogData2,2,v.VehicleId,@tempmult, @liquidmult) < -18 THEN 'Good'
				WHEN dbo.GetScaleConvertAnalogValue(eoff.AnalogData2,2,v.VehicleId,@tempmult, @liquidmult) >= -18 AND dbo.GetScaleConvertAnalogValue(eon.AnalogData2,2,v.VehicleId,@tempmult, @liquidmult) < -15 THEN 'Warning' 
				WHEN dbo.GetScaleConvertAnalogValue(eoff.AnalogData2,2,v.VehicleId,@tempmult, @liquidmult) >= -15 THEN 'Exception'
			END AS TemperatureQuality,
			CAST(100 / stops.Hits AS VARCHAR(3)) + '%' AS LocationAccuracy,
			@tempunit AS TemperatureUnit	
	FROM 
		(SELECT voff.SiteId, voff.VehicleIntId, voff.DriverIntId, voff.VisitId, MIN(voff.Hits) AS Hits, MIN(voff.MinTime) AS EngOff, MAX(von.MaxTime) AS EngOn, MIN(voff.MinEventId) AS OffEventId, MAX(von.MaxEventId) AS OnEventId
		FROM Visits_CTE voff
		INNER JOIN Visits_CTE von ON von.VehicleIntId = voff.VehicleIntId AND von.VisitId = voff.VisitId AND von.CreationCodeId = 87
		WHERE voff.CreationCodeId = 88
		GROUP BY voff.SiteId, voff.VehicleIntId, voff.DriverIntId, voff.VisitId) stops
			INNER JOIN dbo.Vehicle v ON v.VehicleIntId = stops.VehicleIntId
			INNER JOIN dbo.Driver d ON d.DriverIntId = stops.DriverIntId
			INNER JOIN dbo.Geofence geo ON geo.GeofenceId = stops.SiteId
			INNER JOIN dbo.Event eoff WITH (NOLOCK) ON eoff.EventId = stops.OffEventId
			INNER JOIN dbo.Event eon WITH (NOLOCK) ON eon.EventId = stops.OnEventId 

END	


GO
