SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_GetDriverDetails]
(
	@did UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER,
	@date DATETIME = NULL
)
AS
	DECLARE @vid UNIQUEIDENTIFIER
	
	-- Get basic driver details
	SELECT
		[DriverId],
		[DriverIntId],
		[Number],
		[NumberAlternate],
		[NumberAlternate2],
		[FirstName],
		[Surname],
		[MiddleNames],
		[LastOperation],
		[Archived],
		[LanguageCultureId],
		[LicenceNumber],
		[IssuingAuthority],
		[LicenceExpiry],
		[MedicalCertExpiry],
		[Password],
		[PlayInd],
		[DriverType],
        [EmpNumber],
		dbo.FormatDriverNameByUser(@did, @uid) AS DisplayName
	FROM
		[dbo].[Driver]
	WHERE DriverId = @did

	DECLARE @today DATETIME
	SET @today = (SELECT TOP 1 GetDate())
	
	-- Get details of which vehicle the driver is currently driving
	SET @vid = (SELECT TOP 1 VehicleId
				FROM [dbo].[VehicleLatestEvent] e
				WHERE DriverId = @did 
				--AND LatestEventDateTime > DateAdd(day, DatePart(day, @today - 1), @today)
				GROUP BY VehicleId, EventDateTime
				ORDER BY EventDateTime DESC
	)
	
	
	/*
	declare @speedmult float
	declare @timediff nvarchar(30)
	set @speedmult = cast(dbo.[UserPref](@uid,208) as float)
	set @timediff = dbo.[UserPref](@uid, 600)
	
	SELECT TOP 1	
		vle.VehicleId,
		vle.Lat,
		vle.Long,
		dbo.[GetGeofenceNameFromLongLat] (vle.Lat, vle.Long, @uid, dbo.[GetAddressFromLongLat] (vle.Lat, vle.Long)) as ReverseGeoCode,
		vle.Heading,
		cast(vle.Speed * @speedmult as smallint) as Speed,
		dbo.[TZ_GetTime]( vle.EventDateTime, @timediff, @uid) as EventDateTime,
		dbo.[TZ_GetTime]( GetUtcDate(), @timediff, @uid) as QueryTime,
		vle.EventDateTime as GMTEventTime,
		@did AS DriverId
	FROM dbo.VehicleLatestEvent vle
	WHERE DriverId = @did
	*/
	
	--EXECUTE cuf_Vehicle_GetVehicleDetails @vid, @uid, @date




GO
