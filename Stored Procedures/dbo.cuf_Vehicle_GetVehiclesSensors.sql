SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Vehicle_GetVehiclesSensors]
(
	@vids VARCHAR(MAX),
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN

--DECLARE @vids VARCHAR(MAX),
--		@uid UNIQUEIDENTIFIER
--
--SET @vids = N'74EEE16C-CF22-4DE3-B677-B5BBC86BBDC4,97F53C63-1B1D-4760-9DE9-2B09A740A513'
--SET @uid = N'3C65E267-ED53-4599-98C5-CBF5AFD85A66'

SELECT	v.VehicleId, 
		vs.VehicleSensorId, 
		s.SensorType, 
		vs.DigitalSensorTypeId, 
		s.SensorIndex, 
		CASE WHEN vs.DigitalSensorTypeId IS NULL THEN vs.Description ELSE dst.Description END AS Description, 
		CASE WHEN vs.DigitalSensorTypeId IS NULL THEN vs.ShortName ELSE dst.Name END AS ShortName, 
		vs.Colour, 
                    vs.AnalogSensorScaleFactor,
		dst.OnDescription, 
		dst.OffDescription, 
		dst.IconLocation, 
		vs.Enabled, 
		ISNULL(vccactive.CreationCodeHighIsOff,0) AS IsInverted
FROM dbo.VehicleSensor vs
INNER JOIN dbo.Sensor s ON vs.SensorId = s.SensorId
INNER JOIN dbo.Vehicle v ON vs.VehicleIntId = v.VehicleIntId
LEFT JOIN dbo.VehicleCreationCode vccactive ON v.VehicleId = vccactive.VehicleId AND s.CreationCodeIdActive = vccactive.CreationCodeId
LEFT JOIN dbo.DigitalSensorType dst ON vs.DigitalSensorTypeId = dst.DigitalSensorTypeId
WHERE v.VehicleId IN (SELECT VALUE FROM dbo.Split(@vids, ','))
ORDER BY v.VehicleId, s.SensorType, s.SensorIndex  

END



GO
