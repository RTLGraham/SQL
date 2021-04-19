SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[VehicleGeofenceRealTrips_CET]
AS
	SELECT gexit.VehicleIntId AS vehicleIntId, gexit.GeofenceId AS GeofenceId, gexit.ExitDateTime, gentry.EntryDateTime, DATEDIFF(ss, gexit.ExitDateTime, gentry.EntryDateTime) AS ExitSeconds
	FROM

		(SELECT ROW_NUMBER() OVER (PARTITION BY VehicleIntId, GeofenceId ORDER BY EntryDateTime) AS RowNum, *
		FROM dbo.VehicleGeofenceHistory
		  ) gexit
		  
	INNER JOIN 

		(SELECT ROW_NUMBER() OVER (PARTITION BY VehicleIntId, GeofenceId ORDER BY EntryDateTime) AS RowNum, *
		FROM dbo.VehicleGeofenceHistory
		  ) gentry ON gexit.VehicleIntId = gentry.VehicleIntId AND gexit.GeofenceId = gentry.GeofenceId AND gentry.RowNum = gexit.RowNum + 1
		  
	WHERE DATEDIFF(ss, gexit.ExitDateTime, gentry.EntryDateTime) BETWEEN 1800 AND 43200
	  AND CAST(gexit.ExitDateTime AS FLOAT) - FLOOR(CAST(gexit.ExitDateTime AS FLOAT)) > cast(NG_RTL2Application.dbo.TZ_ToUtc('1900-01-01 05:00', 'Central Europe Time', NULL) AS FLOAT)
	  AND CAST(gentry.EntryDateTime AS FLOAT) - FLOOR(CAST(gentry.EntryDateTime AS FLOAT)) < cast(NG_RTL2Application.dbo.TZ_ToUtc('1900-01-01 20:00', 'Central Europe Time', NULL) AS FLOAT)
GO
