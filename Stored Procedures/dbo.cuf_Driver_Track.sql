SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Driver_Track]
(
	@dids NVARCHAR(MAX),
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE @dids NVARCHAR(MAX),
--		@uid UNIQUEIDENTIFIER;
--
--SET @dids = '35B215B7-A306-4855-815A-C51A2B49C145,A1BFA9D5-0FE9-4475-9B9A-CCD77C1816F4,45F09B65-51E7-4A87-9208-2F5ED68D191F,0D572BAC-D832-4D53-A192-7F7C56E1D37B,E7A1C010-1D69-4E0C-9B54-9AD15D1B208C,E3D7AC24-5FCE-419E-9353-EB93ADFA1530,21180525-5D41-4B50-9D77-7D83CEF4BABB'
--SET @uid = 'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

DECLARE @speedmult FLOAT,
		@timediff NVARCHAR(30),
		@curUtcDate DATETIME,
		@vid UNIQUEIDENTIFIER,
		@date DATETIME,
		@queryTime DATETIME

SET @speedmult = CAST(dbo.[UserPref](@uid,208) AS FLOAT)
SET @timediff = dbo.[UserPref](@uid, 600)
SET @curUtcDate = GETUTCDATE()
SET @queryTime = dbo.[TZ_GetTime]( @curUtcDate, @timediff, @uid)

 --receive Track information
SELECT
	d.DriverId,
	dle.Lat,
	dle.Long,
	dbo.[GetGeofenceNameFromLongLat] (dle.Lat, dle.Long, @uid, dbo.[GetAddressFromLongLat] (dle.Lat, dle.Long)) as ReverseGeoCode,
	dle.Heading AS Direction,
	CAST(dle.Speed * @speedmult AS SMALLINT) as Speed,
	dbo.[TZ_GetTime]( dle.EventDateTime, @timediff, @uid) AS EventDateTime,
	@queryTime AS QueryTime,
	dle.EventDateTime AS GMTEventTime,
	ISNULL(dle.VehicleMode, 0) AS VehicleModeId,
	v.VehicleId,
	v.Registration,
	v.VehicleTypeID,
	dle.AnalogIoAlertTypeId,
	dle.OdoGPS,
	dle.OdoRoadSpeed,
	dle.OdoDashboard
FROM [dbo].DriverLatestEvent dle
INNER JOIN dbo.Driver d ON dle.DriverId = d.DriverId
LEFT JOIN dbo.Vehicle v ON dle.VehicleId = v.VehicleId
WHERE dle.DriverId IN (SELECT VALUE FROM dbo.Split(@dids, ','))
OPTION (KEEPFIXED PLAN)

-- receive Vehicle Entity information
SELECT d.*
FROM [dbo].[Driver] d
WHERE DriverId IN (SELECT VALUE	 FROM dbo.Split(@dids, ','))



GO
