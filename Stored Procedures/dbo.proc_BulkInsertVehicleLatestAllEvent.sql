SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_BulkInsertVehicleLatestAllEvent]
AS

-- update/insert rows into VehicleLatestAllEvent table
-- don't change the 'LatestDriverId' column as this is written
-- directly to the live table (not the temp version) by proc_WriteLatestDriver

-- NB keeping rows in Vehicle latest Event temp will remove the need for these tests here against event date time
-- however it will mean that the temp values should be cleared aty each iteration otherwise they will always all be copied to the live tabels.

UPDATE VehicleLatestAllEvent
SET
	VehicleLatestAllEvent.EventDateTime = VehicleLatestAllEventTemp.EventDateTime,
	VehicleLatestAllEvent.EventId = VehicleLatestAllEventTemp.EventId,
	VehicleLatestAllEvent.DriverId = VehicleLatestAllEventTemp.DriverId,
	VehicleLatestAllEvent.CreationCodeId = VehicleLatestAllEventTemp.CreationCodeId,
	VehicleLatestAllEvent.Long = VehicleLatestAllEventTemp.Long,
	VehicleLatestAllEvent.Lat = VehicleLatestAllEventTemp.Lat,
	VehicleLatestAllEvent.Heading = VehicleLatestAllEventTemp.Heading,
	VehicleLatestAllEvent.Speed = VehicleLatestAllEventTemp.Speed,
	VehicleLatestAllEvent.OdoGPS = VehicleLatestAllEventTemp.OdoGPS,	
	VehicleLatestAllEvent.OdoRoadSpeed = VehicleLatestAllEventTemp.odoRoadSpeed,
	VehicleLatestAllEvent.OdoDashboard = VehicleLatestAllEventTemp.OdoDashboard,
	VehicleLatestAllEvent.DigitalIO = VehicleLatestAllEventTemp.DigitalIO,
	VehicleLatestAllEvent.AnalogData0 = VehicleLatestAllEventTemp.AnalogData0,
	VehicleLatestAllEvent.AnalogData1 = VehicleLatestAllEventTemp.AnalogData1,
	VehicleLatestAllEvent.AnalogData2 = VehicleLatestAllEventTemp.AnalogData2,
	VehicleLatestAllEvent.AnalogData3 = VehicleLatestAllEventTemp.AnalogData3,
	VehicleLatestAllEvent.AnalogData4 = VehicleLatestAllEventTemp.AnalogData4,
	VehicleLatestAllEvent.AnalogData5 = VehicleLatestAllEventTemp.AnalogData5
FROM VehicleLatestAllEvent, VehicleLatestAllEventTemp
WHERE VehicleLatestAllEventTemp.EventDateTime >= ISNULL((
			SELECT Event.EventDateTime
			FROM Event
			WHERE Event.EventId = VehicleLatestAllEvent.EventId
				AND Event.Archived = 0
		), '1900-01-01 00:00:00.000')
	AND VehicleLatestAllEvent.VehicleId = VehicleLatestAllEventTemp.VehicleId
	AND VehicleLatestAllEventTemp.Archived = 0
	
-- insert any rows that don't already exist
INSERT INTO dbo.VehicleLatestAllEvent
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
FROM dbo.VehicleLatestAllEventTemp vlet
WHERE NOT EXISTS 
	(SELECT vle.VehicleId
	FROM dbo.VehicleLatestAllEvent vle
	WHERE vle.VehicleId = vlet.VehicleId)
	




GO
