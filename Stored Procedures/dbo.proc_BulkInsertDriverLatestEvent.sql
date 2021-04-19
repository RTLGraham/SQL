SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_BulkInsertDriverLatestEvent]
AS

UPDATE DriverLatestEvent
SET
	DriverLatestEvent.EventDateTime = DriverLatestEventTemp.EventDateTime,
	DriverLatestEvent.EventId = DriverLatestEventTemp.EventId,
	DriverLatestEvent.VehicleId = DriverLatestEventTemp.VehicleId,
	DriverLatestEvent.CreationCodeId = DriverLatestEventTemp.CreationCodeId,
	DriverLatestEvent.Long = DriverLatestEventTemp.Long,
	DriverLatestEvent.Lat = DriverLatestEventTemp.Lat,
	DriverLatestEvent.Heading = DriverLatestEventTemp.Heading,
	DriverLatestEvent.Speed = DriverLatestEventTemp.Speed,
	DriverLatestEvent.OdoGPS = DriverLatestEventTemp.OdoGPS,	
	DriverLatestEvent.OdoRoadSpeed = DriverLatestEventTemp.odoRoadSpeed,
	DriverLatestEvent.OdoDashboard = DriverLatestEventTemp.OdoDashboard,
	DriverLatestEvent.DigitalIO = DriverLatestEventTemp.DigitalIO,
	DriverLatestEvent.AnalogData0 = DriverLatestEventTemp.AnalogData0,
	DriverLatestEvent.AnalogData1 = DriverLatestEventTemp.AnalogData1,
	DriverLatestEvent.AnalogData2 = DriverLatestEventTemp.AnalogData2,
	DriverLatestEvent.AnalogData3 = DriverLatestEventTemp.AnalogData3,
	DriverLatestEvent.AnalogData4 = DriverLatestEventTemp.AnalogData4,
	DriverLatestEvent.AnalogData5 = DriverLatestEventTemp.AnalogData5
FROM DriverLatestEvent, DriverLatestEventTemp
WHERE DriverLatestEventTemp.EventDateTime >= ISNULL((
			SELECT Event.EventDateTime
			FROM Event
			WHERE Event.EventId = DriverLatestEvent.EventId
				AND Event.Archived = 0
		), '1900-01-01 00:00:00.000')
	AND DriverLatestEvent.DriverId = DriverLatestEventTemp.DriverId
	AND DriverLatestEventTemp.Archived = 0
	
-- insert any rows that don't already exist
INSERT INTO dbo.DriverLatestEvent
        ( DriverId ,
          EventId ,
          EventDateTime ,
          VehicleId ,
          CreationCodeId ,
          Long ,
          Lat ,
          Heading ,
          Speed ,
          OdoGPS ,
          OdoRoadSpeed ,
          OdoDashboard ,
          VehicleMode ,
          AnalogIoAlertTypeId ,
          DigitalIO ,
          AnalogData0 ,
          AnalogData1 ,
          AnalogData2 ,
          AnalogData3 ,
          AnalogData4 ,
          AnalogData5
        )
SELECT	  DriverId ,
          EventId ,
          EventDateTime ,
          VehicleId ,
          CreationCodeId ,
          Long ,
          Lat ,
          Heading ,
          Speed ,
          OdoGPS ,
          OdoRoadSpeed ,
          OdoDashboard ,
          VehicleMode ,
          AnalogIoAlertTypeId ,
          DigitalIO ,
          AnalogData0 ,
          AnalogData1 ,
          AnalogData2 ,
          AnalogData3 ,
          AnalogData4 ,
          AnalogData5
FROM dbo.DriverLatestEventTemp dlet
WHERE NOT EXISTS 
	(SELECT dle.DriverId
	FROM dbo.DriverLatestEvent dle
	WHERE dle.DriverId = dlet.DriverId)
	




GO
