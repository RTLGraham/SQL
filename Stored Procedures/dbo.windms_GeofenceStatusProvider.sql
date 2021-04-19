SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[windms_GeofenceStatusProvider]      
      
AS      

-- windms_EDC contains a single row for each geo enter/exit
-- the EventDataString entry for this row is a CSV list of the following
-- GeoDestCode,DriverId,TotalVehicleDistance,TotalFuel
-- GeoDestCode - is currently always 8 digits, this may change
-- DriverID - is as shown on FSeries screen (ie. it's not a DB GUID)
-- TotalDistance - is a decimal number in km (to 1 dp)
-- TotalFuel - is a decimal number in Litres (to 1 dp)
      
SET NOCOUNT ON;      
BEGIN     
	UPDATE dbo.windms_EventsDataCopy SET Archived = 1 WHERE CreationCodeID IN ( 40,41);     
	      
	SELECT	wtv.TruckId,
			[GeoEventType] =
			case 
				when edc.CreationCodeId is null OR edc.CreationCodeId = 41 then 'Exit'
				when edc.CreationCodeId = 40 then 'Entry'
			end, 
			ps.GeoId AS [GeoID],
			dbo.GPSCoord_DegMillionthsToDegMinFrac(ISNULL(e.Lat,0)) AS [Lat],
			dbo.GPSCoord_DegMillionthsToDegMinFrac(ISNULL(e.Long,0)) AS [Long],
			dbo.GPSCoord_DateToYYYYMMDDHHmmss(ISNULL(e.EventDateTime,0)) AS [Time],
			edc.EventId AS [EdcEventId],
			e.CustomerIntId AS [CustomerIntId]
	FROM	dbo.windms_EventDataCopy edc INNER JOIN
			dbo.Event e ON e.EventId = edc.EventId AND e.CustomerIntId = edc.CustomerIntId INNER JOIN
			dbo.windms_TrucksVehicles wtv	ON wtv.VehicleId = dbo.GetVehicleIdFromInt(e.VehicleIntId) AND wtv.Archived = 0
		
--Get the Lomosoft GeoId
-- should split at 1st comma rather than taking left 8 chars
	LEFT JOIN dbo.windms_PlannedStop ps 
	--	ON ps.StopId = CAST(LEFT(edc.EventDataString,8) AS BIGINT)
		ON ps.StopId = (SELECT substring([Value],1,8) FROM dbo.Split(edc.EventDataString,',') WHERE Id = 1)
	WHERE	edc.CreationCodeID IN (40,41) AND edc.Archived = 1  
  
	      

END




GO
