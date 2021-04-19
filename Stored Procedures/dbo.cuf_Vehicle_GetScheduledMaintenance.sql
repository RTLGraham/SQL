SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_GetScheduledMaintenance]
          @uid uniqueidentifier,
          @vids nvarchar(MAX)
AS
          SET NOCOUNT ON;

          DECLARE @distmult FLOAT,
				  @liquidmult FLOAT
		  SELECT @distmult = dbo.UserPref(@uid, 202)
		  SELECT @liquidmult = dbo.UserPref(@uid, 200)

          SELECT    Value
          INTO      #vehicles
          FROM      dbo.Split(@vids, ',');

          SELECT    V.VehicleID,
                    V.Registration,
                    T.VehicleMaintenanceTypeID,
                    S.DistanceInterval * @distmult AS DistanceInterval,
                    S.TimeInterval,
                    S.TimeIntervalWeeks,
                    S.FuelInterval * @liquidmult AS FuelInterval,
                    S.EngineInterval
          FROM      dbo.Vehicle V
                    INNER JOIN #vehicles F ON F.Value = V.VehicleID
                    CROSS JOIN dbo.VehicleMaintenanceType T
                    LEFT OUTER JOIN dbo.VehicleMaintenanceSchedule S
                              ON        S.VehicleIntID = V.VehicleIntID
                              AND       S.VehicleMaintenanceTypeID = T.VehicleMaintenanceTypeID
          ORDER BY  V.Registration, T.VehicleMaintenanceTypeID;

          DROP TABLE #vehicles;
          
GO
