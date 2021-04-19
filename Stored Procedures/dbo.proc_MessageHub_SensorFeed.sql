SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_MessageHub_SensorFeed]
(
          @UserName nvarchar(MAX),
          @Password nvarchar(MAX),
          @DeltaSeconds int
)
AS

DECLARE   @UserID UNIQUEIDENTIFIER,
		  @tempmult FLOAT,
		  @liquidmult FLOAT

SELECT    @UserID = userID
FROM      dbo.[User]
WHERE     Name = @UserName
AND       Password = @Password;

SET @tempmult = ISNULL(dbo.[UserPref](@UserId, 214),1)
SET @liquidmult = ISNULL(dbo.[UserPref](@UserId, 200),1)

SELECT    V.VehicleId,
          V.Registration,
          E.EventDateTime,
          CASE WHEN COALESCE(S1.Enabled, 0) > 0 THEN dbo.GetScaleConvertAnalogValue(E.AnalogData0, 0, v.VehicleId, @tempmult, @liquidmult) ELSE NULL END AS Sensor1,
          CASE WHEN COALESCE(S2.Enabled, 0) > 0 THEN dbo.GetScaleConvertAnalogValue(E.AnalogData1, 1, v.VehicleId, @tempmult, @liquidmult) ELSE NULL END AS Sensor2,
          CASE WHEN COALESCE(S3.Enabled, 0) > 0 THEN dbo.GetScaleConvertAnalogValue(E.AnalogData2, 2, v.VehicleId, @tempmult, @liquidmult) ELSE NULL END AS Sensor3,
          CASE WHEN COALESCE(S4.Enabled, 0) > 0 THEN dbo.GetScaleConvertAnalogValue(E.AnalogData3, 3, v.VehicleId, @tempmult, @liquidmult) ELSE NULL END AS Sensor4,
          E.Lat,
          E.Long,
          E.Heading,
          E.Speed,
          D.Surname + COALESCE(', ' + D.FirstName, '') AS DriverName
FROM      dbo.[User] U
          INNER JOIN CustomerVehicle CV ON CV.CustomerID = U.CustomerID
          INNER JOIN Vehicle V ON V.VehicleId = CV.VehicleId
          INNER JOIN VehicleLatestEvent E ON E.VehicleId = V.VehicleId
          INNER JOIN Driver D ON D.DriverId = E.DriverId
          LEFT OUTER JOIN VehicleSensor S1 ON S1.VehicleIntId = V.VehicleIntId AND S1.SensorId = 1
          LEFT OUTER JOIN VehicleSensor S2 ON S2.VehicleIntId = V.VehicleIntId AND S2.SensorId = 2
          LEFT OUTER JOIN VehicleSensor S3 ON S3.VehicleIntId = V.VehicleIntId AND S3.SensorId = 3
          LEFT OUTER JOIN VehicleSensor S4 ON S4.VehicleIntId = V.VehicleIntId AND S4.SensorId = 4
WHERE     U.UserID = @UserID
AND       E.EventDateTime IS NOT NULL
AND       DATEDIFF(second, E.EventDateTime, GETUTCDATE()) <= @DeltaSeconds;

GO
