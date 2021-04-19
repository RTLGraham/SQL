SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_GetAvailableDigitalSensorsForUser]
	@UserID uniqueidentifier
AS
	SET NOCOUNT ON;

          --DECLARE   @UserID uniqueidentifier;
          --SET       @UserID = 'C2B30F4D-39B7-42BD-B984-218F96AD74A9';

          SELECT    DISTINCT v.Registration, DST.DigitalSensorTypeID, DST.Name, DST.Description, DST.OnDescription, DST.OffDescription, DST.IconLocation
          FROM      dbo.[User] U
                    INNER JOIN CustomerVehicle CV ON CV.CustomerID = U.CustomerID
                    INNER JOIN Vehicle V ON V.VehicleID = CV.VehicleID
                    INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
                    INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
                    INNER JOIN dbo.UserGroup ug ON g.GroupId = ug.GroupId
                    INNER JOIN VehicleSensor VS ON VS.VehicleIntId = V.VehicleIntId
                    INNER JOIN DigitalSensorType DST ON DST.DigitalSensorTypeID = VS.DigitalSensorTypeID
          WHERE     U.UserID = @UserID
					AND g.IsParameter = 0 AND g.Archived = 0 AND g.GroupTypeId = 1
					AND ug.UserId = @UserID
					AND VS.Enabled = 1

GO
