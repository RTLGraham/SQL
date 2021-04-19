SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Stored Procedure

CREATE PROCEDURE [dbo].[proc_Report_ScheduledMaintenance]
          @uid uniqueidentifier,
          @gids nvarchar(MAX),
          @vids nvarchar(MAX)
AS

	--DECLARE @uid uniqueidentifier,
 --           @vids nvarchar(MAX)

	--SET @uid = N'4F96D3BF-9954-4FF3-9819-BED155B9CEBD'
	----SET @vids = N'AD0A6A46-6CC9-490F-AC85-0A986CCDCFD7,7E751C9F-7049-4B4D-BB05-1D9F6CEAEA5C,A103892B-ABD2-42E5-B013-2909D8807691,A2240FD2-36D2-4E21-BD95-4A773F235B4F,4F962C5F-0E2C-461F-929F-A433CF6332C8,135DDA81-5E79-461F-AD59-B95BC8BFE1D2,ABE0B73C-FC5F-4DA3-87E7-EB438F2D3A54'
	--SET @vids = N'4F962C5F-0E2C-461F-929F-A433CF6332C8'

          SET NOCOUNT ON;

          DECLARE @distmult FLOAT,
				  @distunit NVARCHAR(20),
				  @liquidstr varchar(20),
				  @liquidmult FLOAT

		  SELECT @distmult = [dbo].UserPref(@uid, 202)
		  SELECT @distunit = [dbo].UserPref(@uid, 203)
		  SELECT @liquidstr = [dbo].UserPref(@uid, 201)
		  SELECT @liquidmult = [dbo].UserPref(@uid, 200)

          DECLARE @Vehicles TABLE (Value uniqueidentifier);

          INSERT    @Vehicles
          SELECT    Value
          FROM      dbo.Split(@vids, ',');

          SELECT    V.VehicleID,
                    V.VehicleIntID,
                    V.Registration,
                    --ROUND(@distmult*E.OdoDashboard, 0) AS OdoDashboard,
                    --ROUND(@distmult*E.OdoGPS, 0) AS OdoGPS,
					ROUND(@distmult*ISNULL(vlo.OdoGPS,E.OdoDashboard), 0) AS OdoDashboard,
					ROUND(@distmult*ISNULL(vlo.OdoGPS,E.OdoGPS), 0) AS OdoGPS,
                    ROUND(@liquidmult*t.TotalVehicleFuel, 0) AS CurrentFuel,
                    t.TotalEngineHours,
                    S.VehicleMaintenanceTypeID,
                    ROUND(@distmult*(S.DistanceInterval), 0) AS DistanceInterval,
                    S.TimeInterval,
                    S.TimeIntervalWeeks,
                    S.FuelInterval,
                    S.EngineInterval,
                    ROUND(@distmult*S.OdoAtLastMaintenance, 0) AS OdoAtLastMaintenance,
                    S.DateOfLastMaintenance,
                    ROUND(@liquidmult*S.FuelAtLastMaintenance,0) AS FuelAtLastMaintenance,
                    S.EngineAtLastMaintenance,
                    CASE WHEN ISNULL(S.DistanceInterval,0) > 0 THEN ROUND((ISNULL(S.OdoAtLastMaintenance, 0) + S.DistanceInterval) * @distmult, 0) ELSE NULL END AS OdoScheduled,
                    CASE WHEN ISNULL(S.EngineInterval,0) > 0 THEN ROUND((ISNULL(S.EngineAtLastMaintenance, 0) + S.EngineInterval), 0) ELSE NULL END AS EngineScheduled,
                    CASE WHEN ISNULL(S.FuelInterval,0) > 0 THEN ROUND((ISNULL(S.FuelAtLastMaintenance, 0) + S.FuelInterval) * @liquidmult, 0) ELSE NULL END AS FuelScheduled,
                    dbo.GetNextScheduledMaintenanceDate(S.DistanceInterval,S.TimeInterval,S.TimeIntervalWeeks,S.FuelInterval,S.EngineInterval,ISNULL(vlo.OdoGPS,E.OdoGPS),t.TotalVehicleFuel,t.TotalEngineHours,S.DateOfLastMaintenance,S.OdoAtLastMaintenance,S.FuelAtLastMaintenance,S.EngineAtLastMaintenance) AS DateScheduled,
                    CASE WHEN S.DistanceInterval IS NULL AND S.FuelInterval IS NULL AND S.EngineInterval IS NULL AND (S.TimeInterval IS NOT NULL OR S.TimeIntervalWeeks IS NOT NULL) THEN 0 ELSE 1 END AS IsDateEstimate,
                    @distunit AS DistanceUnit,
                    @liquidstr AS FuelUnit
          FROM      dbo.Vehicle V
					LEFT JOIN (
						SELECT v.Value AS VehicleId, a.TotalEngineHours, a.TotalVehicleFuel, ROW_NUMBER() OVER(PARTITION BY v.Value ORDER BY v.Value, a.AccumId DESC) AS RowNum
						FROM dbo.Accum a
						INNER JOIN @Vehicles v ON a.VehicleIntId = dbo.GetVehicleIntFromId(v.Value)
						WHERE a.CreationDateTime > DATEADD(dd, -7, GETDATE())
					) t ON V.VehicleID = t.VehicleId AND t.RowNum = 1
                    INNER JOIN @Vehicles F ON F.Value = V.VehicleID
                    INNER JOIN dbo.VehicleLatestEvent E ON E.VehicleID = V.VehicleID
                    INNER JOIN dbo.VehicleMaintenanceSchedule S ON S.VehicleIntID = V.VehicleIntID
					LEFT JOIN dbo.VehicleLatestOdometer vlo ON vlo.VehicleId = v.VehicleId
          WHERE     S.DistanceInterval IS NOT NULL
          OR        S.TimeInterval IS NOT NULL
          OR        S.FuelInterval IS NOT NULL
          ORDER BY  V.Registration, S.VehicleMaintenanceTypeID;

GO
