SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_ReportGeofence]
( 
	@vehicleIds nvarchar(MAX),
	@geofenceIds nvarchar(MAX),
	@startDate DATETIME,
	@endDate DATETIME,
	@userId UNIQUEIDENTIFIER
)
AS

	--DECLARE @vehicleIds NVARCHAR(MAX),
	--		@geofenceIds NVARCHAR(MAX),
	--		@startDate DATETIME,
	--		@endDate DATETIME,
	--		@userId UNIQUEIDENTIFIER

	--SET @vehicleIds = N'67B44E7F-6A0E-42E0-9DCF-5DDCA2AF502E'
	--SET @startDate = '2015-07-01 00:00:00'
	--SET @endDate = '2015-07-07 23:59:00'
	--SET @userId = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
	--SET @geofenceIds = N'EC5CEEAC-9E02-4951-B87C-1DC95CF6F642'


	-- Section added to allow the report to be automatically scheduled
	IF datepart(yyyy, @startDate) = '1960'
	BEGIN
		SET @endDate = dbo.Calc_Schedule_EndDate(@startDate, @userId)
		SET @startDate = dbo.Calc_Schedule_StartDate(@startDate, @userId)
	END
	
	DECLARE @rawData TABLE
	(
		VehicleId UNIQUEIDENTIFIER, 
		GeoFenceId UNIQUEIDENTIFIER, 
		GeomType VARCHAR(100), 
		[Entry] DATETIME,
		Geofencename NVARCHAR(MAX), 
		Geofencecategory INT, 
		GeofenceType INT, 
		Note NVARCHAR(MAX), 
		Registration NVARCHAR(MAX)
	)

	INSERT INTO @rawData
	EXEC cu_Geofence_ReportOptimal @vehicleIds, @geofenceIds, @userId, @startDate, @endDate
	
	

	SELECT v.Registration, g.Name AS GeofenceName, entries.Entry AS DateEnteredGeofence, MIN(exits.Entry) AS DateLeftGeofence, (MIN(exits.Entry) - entries.Entry) AS TimeSpentInGeofence, 
		@startDate AS CreationDateTime, @endDate AS ClosureDateTime
	FROM @rawData entries
		INNER JOIN dbo.Vehicle v ON v.VehicleId = entries.VehicleId
		INNER JOIN dbo.Geofence g ON g.GeoFenceId = entries.GeoFenceId 
		LEFT OUTER JOIN @rawData exits ON exits.GeoFenceId = entries.GeoFenceId AND exits.VehicleId = entries.VehicleId AND exits.[Entry] > entries.[Entry] AND exits.GeomType = 'O'
	WHERE entries.GeomType = 'I'
	GROUP BY v.Registration, g.Name, entries.Entry
	ORDER BY v.Registration, g.Name, entries.Entry ASC
	
	--EXECUTE [dbo].[clr_Geofence_Report] 
	--   @vehicleIds
	--  ,@geofenceIds
	--  ,@startDate
	--  ,@endDate
	--  ,@userId
GO
