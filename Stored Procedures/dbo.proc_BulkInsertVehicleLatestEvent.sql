SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_BulkInsertVehicleLatestEvent]
AS

-- update/insert rows into VehicleLatestEvent table
-- don't change the 'LatestDriverId' column as this is written
-- directly to the live table (not the temp version) by proc_WriteLatestDriver

-- Only update the Odo values if they are non zero

-- NB keeping rows in Vehicle latest Event temp will remove the need for these tests here against event date time
-- however it will mean that the temp values should be cleared at each iteration otherwise they will always all be copied to the live tables.

UPDATE VehicleLatestEvent
SET
	VehicleLatestEvent.EventDateTime = VehicleLatestEventTemp.EventDateTime,
	VehicleLatestEvent.EventId = VehicleLatestEventTemp.EventId,
	VehicleLatestEvent.DriverId = VehicleLatestEventTemp.DriverId,
	VehicleLatestEvent.CreationCodeId = VehicleLatestEventTemp.CreationCodeId,
	VehicleLatestEvent.Long = VehicleLatestEventTemp.Long,
	VehicleLatestEvent.Lat = VehicleLatestEventTemp.Lat,
	VehicleLatestEvent.Heading = VehicleLatestEventTemp.Heading,
	VehicleLatestEvent.Speed = VehicleLatestEventTemp.Speed,
	VehicleLatestEvent.OdoGPS = CASE WHEN VehicleLatestEventTemp.OdoGPS = 0 THEN VehicleLatestEvent.OdoGPS ELSE VehicleLatestEventTemp.OdoGPS END,	
	VehicleLatestEvent.OdoRoadSpeed = CASE WHEN VehicleLatestEventTemp.odoRoadSpeed = 0 THEN VehicleLatestEvent.odoRoadSpeed ELSE VehicleLatestEventTemp.odoRoadSpeed END,
	VehicleLatestEvent.OdoDashboard = CASE WHEN VehicleLatestEventTemp.OdoDashboard = 0 THEN VehicleLatestEvent.OdoDashboard ELSE VehicleLatestEventTemp.OdoDashboard END,
	VehicleLatestEvent.DigitalIO = VehicleLatestEventTemp.DigitalIO,
	VehicleLatestEvent.AnalogData0 = VehicleLatestEventTemp.AnalogData0,
	VehicleLatestEvent.AnalogData1 = VehicleLatestEventTemp.AnalogData1,
	VehicleLatestEvent.AnalogData2 = VehicleLatestEventTemp.AnalogData2,
	VehicleLatestEvent.AnalogData3 = VehicleLatestEventTemp.AnalogData3,
	VehicleLatestEvent.AnalogData4 = VehicleLatestEventTemp.AnalogData4,
	VehicleLatestEvent.AnalogData5 = VehicleLatestEventTemp.AnalogData5
FROM VehicleLatestEvent, VehicleLatestEventTemp
WHERE VehicleLatestEventTemp.EventDateTime >= ISNULL((
			SELECT Event.EventDateTime
			FROM Event
			WHERE Event.EventId = VehicleLatestEvent.EventId
				AND Event.Archived = 0
		), '1900-01-01 00:00:00.000')
	AND VehicleLatestEvent.VehicleId = VehicleLatestEventTemp.VehicleId
	AND VehicleLatestEventTemp.Archived = 0
	
-- insert any rows that don't already exist
INSERT INTO dbo.VehicleLatestEvent
        ( VehicleId ,
          EventId ,
          EventDateTime ,
          DriverId ,
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
SELECT	  VehicleId ,
          EventId ,
          EventDateTime ,
          DriverId ,
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
FROM dbo.VehicleLatestEventTemp vlet
WHERE NOT EXISTS 
	(SELECT vle.VehicleId
	FROM dbo.VehicleLatestEvent vle
	WHERE vle.VehicleId = vlet.VehicleId)
	




GO
