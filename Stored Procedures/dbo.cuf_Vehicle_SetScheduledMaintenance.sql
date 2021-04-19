SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_SetScheduledMaintenance]
          @uid uniqueidentifier,
          @vids nvarchar(MAX),
          @maintType int,
          @distanceInterval int = NULL,
          @timeInterval int = NULL,
          @timeIntervalWeeks int = NULL,
          @fuelInterval int = NULL,
          @engineInterval INT = NULL
AS
          SET NOCOUNT ON;

          DECLARE @distmult FLOAT,
				  @liquidmult FLOAT
		  SELECT @distmult = dbo.UserPref(@uid, 202)
		  SELECT @liquidmult = dbo.UserPref(@uid, 200)

          SELECT    V.VehicleIntID AS ID
          INTO      #vehicles
          FROM      dbo.Split(@vids, ',') F
                    INNER JOIN Vehicle V ON V.VehicleID = F.Value;

          --First, add records for vehicles that don't have them yet
          INSERT    VehicleMaintenanceSchedule(VehicleIntID, VehicleMaintenanceTypeID)
          SELECT    ID, @maintType
          FROM      #vehicles
          EXCEPT
          SELECT    VehicleIntID, VehicleMaintenanceTypeID
          FROM      VehicleMaintenanceSchedule;

          --Then, update all the schedules at once
          UPDATE    S
          SET       DistanceInterval = @distanceInterval/@distmult,
                    TimeInterval = @timeInterval,
                    TimeIntervalWeeks = @timeIntervalWeeks,
                    FuelInterval = @fuelInterval/@liquidmult,
                    EngineInterval = @engineInterval
          FROM      VehicleMaintenanceSchedule S
                    INNER JOIN #vehicles F ON F.ID = S.VehicleIntID
          WHERE     S.VehicleMaintenanceTypeID = @maintType;

          DROP TABLE #vehicles;
          
          
GO
