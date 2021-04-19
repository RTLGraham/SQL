SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ===========================================================================================
-- Author:		Graham Pattison
-- Create date: 08/11/2018
-- Description:	Creates empty Reporting rows based on previous day's Reporting table entries.
--				The latest Odometer value is carried forward to the Earliest Odometer.
--				Entries are only created if an enrty does not already exist.
--				This process mainatins the continuity of cached Odometer values foe every day.
-- ===========================================================================================
CREATE PROCEDURE [dbo].[proc_DailyInitialiseReporting]
AS

INSERT INTO dbo.Reporting
        (VehicleIntId,
         DriverIntId,
         InSweetSpotDistance,
         FueledOverRPMDistance,
         TopGearDistance,
         CruiseControlDistance,
         CoastInGearDistance,
         IdleTime,
         TotalTime,
         EngineBrakeDistance,
         ServiceBrakeDistance,
         EngineBrakeOverRPMDistance,
         ROPCount,
         OverSpeedDistance,
         CoastOutOfGearDistance,
         PanicStopCount,
         TotalFuel,
         TimeNoID,
         TimeID,
         DrivingDistance,
         PTOMovingDistance,
         Date,
         Rows,
         DrivingFuel,
         PTOMovingTime,
         PTOMovingFuel,
         PTONonMovingTime,
         PTONonMovingFuel,
         DigitalInput2Count,
         RouteID,
         PassengerComfort,
         ORCount,
         CruiseInTopGearsDistance,
         GearDownDistance,
         ROP2Count,
         CruiseSpeedingDistance,
         OverSpeedThresholdDistance,
         TopGearSpeedingDistance,
         FuelWastage,
         EarliestOdoGPS,
         LatestOdoGPS
        )
SELECT r.VehicleIntId, r.DriverIntId, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME), 0, 0, 0, 0, 0, 0, 0, r.RouteID, 0, 0, 0, 0, 0, 0, 0, 0, 0, r.LatestOdoGPS, r.LatestOdoGPS
FROM dbo.Reporting r
WHERE FLOOR(CAST(r.Date AS FLOAT)) = FLOOR(CAST(DATEADD(dd, -1, GETDATE()) AS FLOAT))
  AND NOT EXISTS   (SELECT *
					FROM dbo.Reporting today WHERE today.VehicleIntId = r.VehicleIntId 
											   AND today.DriverIntId = r.DriverIntId  
											   AND ISNULL(today.RouteID, 0) = ISNULL(r.RouteID, 0) 
											   AND today.Date = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME))


GO
