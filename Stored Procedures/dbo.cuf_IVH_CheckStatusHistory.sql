SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_IVH_CheckStatusHistory]
(
	@userid UNIQUEIDENTIFIER,
	@vid UNIQUEIDENTIFIER
)
AS

	--DECLARE @userid UNIQUEIDENTIFIER,
	--		@vid UNIQUEIDENTIFIER

	--SET @userid = N'2169C8F9-8157-42BC-9EBB-3085D6F72FCB'
	--SET @vid = N'A6B1F69C-87D7-4444-81AD-E0EA50760BF4'

	--SELECT * FROM dbo.Vehicle WHERE Registration LIKE '%jhk%'
	--SELECT * FROM dbo.[User] WHERE Name LIKE '%eng%'

	SELECT  d.DiagnosticsId,
			d.UserId,
			dbo.TZ_GetTime(d.Date,DEFAULT,@userid) AS Date,
			dbo.TZ_GetTime(d.IgnitionDateTime,DEFAULT,@userid) AS IgnitionDateTime,
			--dbo.TZ_GetTime(@dbTime,DEFAULT,@userid) AS LastEventDateTime,
			dbo.TZ_GetTime(d.LastEventDateTime,DEFAULT,@userid) AS LastEventDateTime,
			d.TotalDistance AS TotalVehicleDistance,
			d.AverageRPM,
			d.TotalFuel,
			d.DrivingFuel,
			d.ShortIdleFuel,
			d.TotalIdleTime,
			d.GPSSatelliteCount,
			d.DriverNumber,
			d.Sensor0,
			d.Sensor0Max,
			d.Sensor0Min,
			d.Sensor0Current,
			d.Sensor1,
			d.Sensor1Max,
			d.Sensor1Min,
			d.Sensor1Current,
			d.Sensor2,
			d.Sensor2Max,
			d.Sensor2Min,
			d.Sensor2Current,
			d.Sensor3,
			d.Sensor3Max,
			d.Sensor3Min,
			d.Sensor3Current,
			d.DigitalIO1,
			d.DigitalIO2,
			d.DigitalIO3,
			d.DigitalIO4,
			d.CustomerName,
			d.VehicleGroups,
			d.Version AS SoftwareVersion,
			d.Website,
			d.Network,
			d.Com1,
			d.Com2,
			d.CanType,
			d.Options,
			d.SensorConfig,
			d.Registration,
			d.TrackerNumber,
			d.AccumStart,
			d.AccumEnd,
			d.AccumCount,
            d.CameraSerial ,
            d.LastCameraEventDateTime ,
            d.CameraState ,
            d.CameraFirmware ,
            d.CameraVideoId ,
            d.CameraVideoType ,
            d.CameraVideoState ,
			d.HardwareStatus ,
	        d.DIG_DigidownTConnected ,
	        d.DIG_TachographConnected,

			CASE WHEN d.CompletedDateTime IS NULL THEN 0 ELSE 1 END AS IsCompleted,
			dbo.TZ_GetTime(d.CompletedDateTime,DEFAULT,@userid) AS CompletedDateTimeUserTime,
			dbo.TZ_GetTime(d.CompletedDateTime,DEFAULT,u.UserID) AS CompletedDateTimeEngineerTime,
			u.Name AS EngineerUserName,
			LTRIM(RTRIM(ISNULL(u.Name,'') + CASE WHEN u.Name IS NULL THEN '' ELSE ' ' END + ISNULL(u.Surname,''))) AS EngineerName,
			d.IVHId,
			d.VehicleId,
			d.CameraID,

			d.MakeModel ,
			d.BodyManufacturer ,
			d.BodyType ,
			d.ChassisNumber ,
			d.Odometer ,
			d.Comment ,
			d.CameraSIMICCID ,
			d.CameraSIMDataUsage ,
			d.CameraSIMRatePlan ,
			d.CameraSIMStatus ,
			d.CameraSIMLimitReached ,
			d.CameraSIMLastSession ,
			d.PulsFirstId ,
			d.PulsLastId ,
			d.PulsLastConfigUpdate ,
			d.PulsConfigStatus ,
			d.PulsConfigGroup,
			d.JobType,
			d.JobReference
			
	FROM dbo.Diagnostics d
		INNER JOIN dbo.[User] u ON u.UserID = d.UserId
	WHERE VehicleId = @vid
	ORDER BY DiagnosticsId DESC

GO
