SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =========================================================================================
-- Author:		Graham Pattison
-- Create date: 28/02/2011
-- Description:	Insert successully matching potential triggers into TAN_NotificationsPending
-- =========================================================================================
CREATE PROCEDURE [dbo].[proc_windms_GeofenceOutput]
AS

DECLARE @WindmsGeofences TABLE (
	[TruckId] [bigint] NULL,
	[GeoEventType] [varchar](10) NULL,
	[GeoID] [varchar](50) NULL,
	[Lat] [varchar](50) NULL,
	[Long] [varchar](50) NULL,
	[Time] [varchar](50) NULL,
	[GeoDestCode] [varchar](50) NULL,
	[DriverId] [varchar](20) NULL,
	[TotalDistance] [varchar] (20) NULL,
	[TotalFuel] [varchar](20) NULL,
	[EdcEventId] [bigint] NULL,
	[CustomerIntId] [int] NULL)

-- Mark rows for processing in windms_EventsDataCopy
UPDATE windms_EventsDataCopy SET Archived = 1 WHERE CreationCodeID IN (40,41);     

-- Determine candidate data and insert into table variable
INSERT INTO @WindmsGeofences
        ( TruckId ,
          GeoEventType ,
          GeoID ,
          Lat ,
          Long ,
          Time ,
          GeoDestCode ,
          DriverId ,
          TotalDistance ,
          TotalFuel ,
          EdcEventId ,
          CustomerIntId )
SELECT	wtv.TruckId AS [TruckId],
		[GeoEventType] =
		case 
			when edc.CreationCodeId is null OR edc.CreationCodeId = 41 then 'Exit'
			when edc.CreationCodeId = 40 then 'Entry'
		end, 
		ps.GeoId AS [GeoID],
		dbo.GPSCoord_DegMillionthsToDegMinFrac(ISNULL(e.Lat,0)) AS [Lat],
		dbo.GPSCoord_DegMillionthsToDegMinFrac(ISNULL(e.Long,0)) AS [Long],
		dbo.GPSCoord_DateToYYYYMMDDHHmmss(ISNULL(e.EventDateTime,0)) AS [Time],
		(SELECT [Value] FROM dbo.Split(edc.EventDataString,',') WHERE Id = 1) AS [GeoDestCode],
		(SELECT [Value] FROM dbo.Split(edc.EventDataString,',') WHERE Id = 2)	AS [DriverID],
		(SELECT [Value] FROM dbo.Split(edc.EventDataString,',') WHERE Id = 3) AS [TotalDistance],
		(SELECT [Value] FROM dbo.Split(dbo.String_TrimNull(edc.EventDataString),',') WHERE Id = 4) AS [TotalFuel],
		edc.EventId AS [EdcEventId],
		e.CustomerIntId AS [CustomerIntId]
FROM	windms_EventsDataCopy edc 
INNER JOIN Event e ON e.EventId = edc.EventId AND e.CustomerIntId = edc.CustomerIntId
INNER JOIN windms_TrucksVehicles wtv ON dbo.GetVehicleIntFromId(wtv.VehicleId) = e.VehicleIntId AND wtv.Archived = 0		
LEFT JOIN windms_PlannedStop ps ON ps.StopId = (SELECT substring([Value],1,8) FROM dbo.Split(edc.EventsDataString,',') WHERE Id = 1)
WHERE	edc.CreationCodeID IN (40,41) AND edc.Archived = 1

-- Select rows from table variable to insert into GeofenceStatusChronicle
INSERT INTO GeofenceStatusChronicle (TruckId, GeoEventType, GeoId, Lat, long, Time, EdcEventId, CustomerIntId)
SELECT	[TruckId],
		[GeoEventType],
		[GeoID],
		[Lat],
		[Long],
		[Time],
		[EdcEventId],
		[CustomerIntId]
FROM	@windmsGeofences

-- Select rows from table variable to Generate XML for output
SELECT	[TruckId],
		[GeoEventType],
		[GeoID],
		[Lat],
		[Long],
		[Time],
		[GeoDestCode],
		[DriverID],
		[TotalDistance],
		[TotalFuel]
FROM	@WindmsGeofences
FOR XML RAW('GeoResponse'), ELEMENTS

-- Delete processed rows from windms_EventsDataCopy
DELETE FROM windms_EventsDataCopy WHERE CreationCodeID IN (40,41) AND Archived = 1;



GO
