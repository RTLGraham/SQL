SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_UpdateLastScheduledMaintenance]
          @uid uniqueidentifier,
          @vid uniqueidentifier,
          @maintType int,
          @date smalldatetime,
          @odo int,
          @fuel INT,
          @engine int
AS
          SET NOCOUNT ON;

          DECLARE @distmult FLOAT,
				  @liquidmult FLOAT

		  SELECT @distmult = dbo.UserPref(@uid, 202)
		  SELECT @liquidmult = dbo.UserPref(@uid, 200)

          UPDATE    S
          SET       DateOfLastMaintenance = @date,
                    OdoAtLastMaintenance = ROUND(@odo/@distmult, 0),
                    FuelAtLastMaintenance = ROUND(@fuel/@liquidmult, 0),
                    EngineAtLastMaintenance = @engine
          FROM      VehicleMaintenanceSchedule S
                    INNER JOIN Vehicle V ON V.VehicleIntID = S.VehicleIntID
          WHERE     V.VehicleID = @vid
          AND       S.VehicleMaintenanceTypeID = @maintType;

GO
