SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportPerformance_Individual_Vehicle_RS]
    (
      @vid UNIQUEIDENTIFIER,
      @sdate DATETIME,
      @edate DATETIME,
      @uid UNIQUEIDENTIFIER,
      @rprtcfgid UNIQUEIDENTIFIER
    )
AS --DECLARE	@vid uniqueidentifier,
--		@sdate datetime,
--		@edate datetime,
--		@uid uniqueidentifier,
--		@rprtcfgid uniqueidentifier
--
--SET @vid = N'FE483F0A-4F3E-4C08-9132-B3BD76A1F377'
--SET @sdate = '2011-04-04 00:00:00'
--SET @edate = '2011-06-24 23:59:59'
--SET @uid = N'4c0a0d44-0685-4292-9087-f32e03f10134'
--SET @rprtcfgid = N'3FED49AA-15C3-4875-A980-D252A6DAEF80'

    DECLARE @diststr VARCHAR(20),
        @distmult FLOAT,
        @fuelstr VARCHAR(20),
        @fuelmult FLOAT,
        @co2str VARCHAR(20),
        @co2mult FLOAT

    SELECT  @diststr = [dbo].UserPref(@uid, 203)
    SELECT  @distmult = [dbo].UserPref(@uid, 202)
    SELECT  @fuelstr = [dbo].UserPref(@uid, 205)
    SELECT  @fuelmult = [dbo].UserPref(@uid, 204)
    SELECT  @co2str = [dbo].UserPref(@uid, 211)
    SELECT  @co2mult = [dbo].UserPref(@uid, 210)

    SET @sdate = [dbo].TZ_ToUTC(@sdate, DEFAULT, @uid)
    SET @edate = [dbo].TZ_ToUTC(@edate, DEFAULT, @uid)

    DECLARE @period_dates TABLE
        (
          WeekNumber INT,
          WStartDate DATETIME,
          WEndDate DATETIME
        )

    INSERT  INTO @period_dates
            (
              WeekNumber,
              WStartDate,
              WEndDate
            )
    VALUES  (
              0,
              DATEADD(dd, -7, @sdate),
              DATEADD(dd, -1, @sdate)
            )
    INSERT  INTO @period_dates
            (
              WeekNumber,
              WStartDate,
              WEndDate
            )
    VALUES  (
              1,
              @sdate,
              DATEADD(dd, 6, @sdate)
            )
    INSERT  INTO @period_dates
            (
              WeekNumber,
              WStartDate,
              WEndDate
            )
    VALUES  (
              2,
              DATEADD(dd, 7, @sdate),
              DATEADD(dd, 13, @sdate)
            )
    INSERT  INTO @period_dates
            (
              WeekNumber,
              WStartDate,
              WEndDate
            )
    VALUES  (
              3,
              DATEADD(dd, 14, @sdate),
              DATEADD(dd, 20, @sdate)
            )
    INSERT  INTO @period_dates
            (
              WeekNumber,
              WStartDate,
              WEndDate
            )
    VALUES  (
              4,
              DATEADD(dd, 21, @sdate),
              DATEADD(dd, 27, @sdate)
            )
    INSERT  INTO @period_dates
            (
              WeekNumber,
              WStartDate,
              WEndDate
            )
    VALUES  (
              5,
              DATEADD(dd, 28, @sdate),
              DATEADD(dd, 34, @sdate)
            )

    DECLARE @ResultSet TABLE
        (
          VehicleId UNIQUEIDENTIFIER,
          Registration VARCHAR(20),
          DriverId UNIQUEIDENTIFIER,
          DriverName VARCHAR(100),
          WeekNumber INT,
          WStartDate DATETIME,
          WEndDate DATETIME,
          Score FLOAT,
          IsScoreBetter BIT,
          TotalDrivingDistance FLOAT,
          SweetSpot FLOAT,
          Idle FLOAT,
          OverRevWithFuel FLOAT,
          Cruise FLOAT,
          EngineServiceBrake FLOAT,
          HarshBraking FLOAT,
          CoastInGear FLOAT,
          OverSpeed FLOAT,
          Rop FLOAT,
          OverRevWithoutFuel FLOAT,
          Pto INT,
          FuelEcon FLOAT,
          sdate DATETIME,
          edate DATETIME,
          DistanceUnit VARCHAR(20),
          FuelUnit VARCHAR(20),
          ScoreColour VARCHAR(10),
          SweetSpotColour VARCHAR(10),
          IdleColour VARCHAR(10),
          OverRevWithFuelColour VARCHAR(10),
          CruiseColour VARCHAR(10),
          EngineServiceBrakeColour VARCHAR(10),
          HarshBrakingColour VARCHAR(10),
          CoastInGearColour VARCHAR(10)
        )

    INSERT  INTO @ResultSet
            (
              VehicleId,
              Registration,
              DriverId,
              DriverName,
              WeekNumber,
              WStartDate,
              WEndDate,
              Score,
              IsScoreBetter,
              TotalDrivingDistance,
              SweetSpot,
              Idle,
              OverRevWithFuel,
              Cruise,
              EngineServiceBrake,
              HarshBraking,
              CoastInGear,
              OverSpeed,
              Rop,
              OverRevWithoutFuel,
              Pto,
              FuelEcon,
              sdate,
              edate,
              DistanceUnit,
              FuelUnit,
              ScoreColour,
              SweetSpotColour,
              IdleColour,
              OverRevWithFuelColour,
              CruiseColour,
              EngineServiceBrakeColour,
              HarshBrakingColour,
              CoastInGearColour
            )
            SELECT  *
            FROM    ( SELECT    v.VehicleId,
                                Registration,
                                d.DriverId,
                                d.Surname + ' ' + d.Firstname as DriverName,
                                WeekNumber,
                                WStartDate,
                                WEndDate,
                                Score,
                                IsScoreBetter,
                                TotalDrivingDistance,
                                SweetSpot,
                                Idle,
                                OverRevWithFuel,
                                Cruise,
                                EngineServiceBrake,
                                HarshBraking,
                                CoastInGear,
                                OverSpeed,
                                Rop,
                                OverRevWithoutFuel,
                                Pto,
                                FuelEcon,
                                @sdate AS sdate,
                                @edate AS edate,
                                @diststr AS DistanceUnit,
                                @fuelstr AS FuelUnit,
                                dbo.GYRColourConfig(Score, 18, @rprtcfgid) AS ScoreColour,
                                dbo.GYRColourConfig(SweetSpot * 100, 1,
                                                    @rprtcfgid) AS SweetSpotColour,
                                dbo.GYRColourConfig(Idle * 100, 6, @rprtcfgid) AS IdleColour,
                                dbo.GYRColourConfig(OverRevWithFuel * 100, 2,
                                                    @rprtcfgid) AS OverRevWithFuelColour,
                                dbo.GYRColourConfig(Cruise * 100, 4,
                                                    @rprtcfgid) AS CruiseColour,
                                dbo.GYRColourConfig(EngineServiceBrake * 100,
                                                    7, @rprtcfgid) AS EngineServiceBrakeColour,
                                dbo.GYRColourConfig(HarshBraking, 12,
                                                    @rprtcfgid) AS HarshBrakingColour,
                                dbo.GYRColourConfig(CoastInGear * 100, 5,
                                                    @rprtcfgid) AS CoastInGearColour
                      FROM      ( SELECT    *,
                                            Score = dbo.ScorePerformanceConfig(SweetSpot, OverRevWithFuel, NULL, Cruise, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, NULL, HarshBraking, NULL, @rprtcfgid),
                                            NULL AS IsScoreBetter
                                  FROM      ( SELECT    CASE WHEN ( GROUPING(v.VehicleId) = 1 )
                                                             THEN NULL
                                                             ELSE ISNULL(v.VehicleId, NULL)
                                                        END AS VehicleId,
                                                        CASE WHEN ( GROUPING(d.DriverId) = 1 )
                                                             THEN NULL
                                                             ELSE ISNULL(d.DriverId, NULL)
                                                        END AS DriverId,
                                                        CASE WHEN ( GROUPING(WeekNumber) = 1 )
                                                             THEN NULL
                                                             ELSE ISNULL(WeekNumber, NULL)
                                                        END AS WeekNumber,
                                                        MIN(WStartDate) AS WStartDate,
                                                        MIN(WEndDate) AS WEndDate,
                                                        SUM(InSweetSpotDistance)
                                                        / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS SweetSpot,
                                                        SUM(FueledOverRPMDistance)
                                                        / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS OverRevWithFuel,
                                                        SUM(CruiseControlDistance)
                                                        / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS Cruise,
                                                        SUM(CoastInGearDistance)
                                                        / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS CoastInGear,
                                                        CAST(SUM(IdleTime) AS FLOAT)
                                                        / dbo.ZeroYieldNull(SUM(TotalTime)) AS Idle,
                                                        CAST(SUM(PTOMovingTime)
                                                        + SUM(PTONonMovingTime) AS FLOAT)
                                                        / dbo.ZeroYieldNull(SUM(TotalTime)) AS Pto,
                                                        ISNULL(SUM(EngineBrakeDistance) / dbo.ZeroYieldNull(SUM(ServiceBrakeDistance + EngineBrakeDistance)), 0) AS EngineServiceBrake,
                                                        ISNULL(SUM(EngineBrakeOverRPMDistance) / dbo.ZeroYieldNull(SUM(EngineBrakeDistance)), 0) AS OverRevWithoutFuel,
                                                        ISNULL(( SUM(ROPCount) * ( dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull(( SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000 ))) ) ), 0) AS Rop,
                                                        ISNULL(SUM(OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)), 0) AS OverSpeed,
                                                        ISNULL(( SUM(PanicStopCount) * ( dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull(( SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000 ))) ) ), 0) AS HarshBraking,
                                                        SUM(DrivingDistance
                                                            * 1000 * @distmult) AS TotalDrivingDistance,
                                                        ( CASE WHEN @fuelmult = 0.1 THEN ( CASE WHEN SUM(TotalFuel) = 0 THEN NULL
                                                                                                ELSE SUM(TotalFuel * ISNULL(FuelMultiplier, 1.0)) * 100
                                                                                           END ) / SUM(DrivingDistance + PTOMovingDistance)
                                                               ELSE ( SUM(DrivingDistance + PTOMovingDistance) * 1000 ) / ( CASE WHEN SUM(TotalFuel) = 0 THEN NULL
                                                                                                                                 ELSE SUM(TotalFuel * ISNULL(FuelMultiplier, 1.0))
                                                                                                                            END ) * @fuelmult
                                                          END ) AS FuelEcon
                                              FROM      dbo.Reporting
														INNER JOIN dbo.Vehicle v ON Reporting.VehicleIntId = v.VehicleIntId
														INNER JOIN dbo.Driver d ON Reporting.DriverIntId = d.DriverIntId
                                                        INNER JOIN @period_dates p ON Reporting.Date BETWEEN p.WStartDate
                                                                                                     AND     p.WEndDate
                                              WHERE     Date BETWEEN @sdate AND @edate
                                                        AND v.VehicleId = @vid
                                                        AND p.WeekNumber > 0
                                              GROUP BY  d.DriverId,
                                                        v.VehicleId,
                                                        WeekNumber
                                                        WITH CUBE
                                              HAVING    SUM(DrivingDistance) > 10
                                            ) o
                                ) p
                                LEFT JOIN dbo.Vehicle v ON p.VehicleId = v.VehicleId
                                LEFT JOIN dbo.Driver d ON p.DriverId = d.DriverId
                    ) CubeResult
            WHERE   CubeResult.VehicleId = @vid
                    AND NOT ( WeekNumber IS NULL
                              AND DriverId IS NOT NULL
                            )
            UNION -- get prior week data independently so cube totals unaffected and can provide IsBetter for week 5
            SELECT  *
            FROM    ( SELECT    v.VehicleId,
                                Registration,
                                d.DriverId,
                                d.Surname + ' ' + d.Firstname as DriverName,
                                WeekNumber,
                                WStartDate,
                                WEndDate,
                                Score,
                                IsScoreBetter,
                                TotalDrivingDistance,
                                SweetSpot,
                                Idle,
                                OverRevWithFuel,
                                Cruise,
                                EngineServiceBrake,
                                HarshBraking,
                                CoastInGear,
                                OverSpeed,
                                Rop,
                                OverRevWithoutFuel,
                                Pto,
                                FuelEcon,
                                @sdate AS sdate,
                                @edate AS edate,
                                @diststr AS DistanceUnit,
                                @fuelstr AS FuelUnit,
                                dbo.GYRColourConfig(Score, 18, @rprtcfgid) AS ScoreColour,
                                dbo.GYRColourConfig(SweetSpot * 100, 1,
                                                    @rprtcfgid) AS SweetSpotColour,
                                dbo.GYRColourConfig(Idle * 100, 6, @rprtcfgid) AS IdleColour,
                                dbo.GYRColourConfig(OverRevWithFuel * 100, 2,
                                                    @rprtcfgid) AS OverRevWithFuelColour,
                                dbo.GYRColourConfig(Cruise * 100, 4,
                                                    @rprtcfgid) AS CruiseColour,
                                dbo.GYRColourConfig(EngineServiceBrake * 100,
                                                    7, @rprtcfgid) AS EngineServiceBrakeColour,
                                dbo.GYRColourConfig(HarshBraking, 12,
                                                    @rprtcfgid) AS HarshBrakingColour,
                                dbo.GYRColourConfig(CoastInGear * 100, 5,
                                                    @rprtcfgid) AS CoastInGearColour
                      FROM      ( SELECT    *,
                                            Score = dbo.ScorePerformanceConfig(SweetSpot, OverRevWithFuel, NULL, Cruise, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, NULL, HarshBraking, NULL, @rprtcfgid),
                                            NULL AS IsScoreBetter
                                  FROM      ( SELECT    CASE WHEN ( GROUPING(v.VehicleId) = 1 )
                                                             THEN NULL
                                                             ELSE ISNULL(v.VehicleId, NULL)
                                                        END AS VehicleId,
                                                        CASE WHEN ( GROUPING(d.DriverId) = 1 )
                                                             THEN NULL
                                                             ELSE ISNULL(d.DriverId, NULL)
                                                        END AS DriverId,
                                                        CASE WHEN ( GROUPING(WeekNumber) = 1 )
                                                             THEN NULL
                                                             ELSE ISNULL(WeekNumber, NULL)
                                                        END AS WeekNumber,
                                                        MIN(WStartDate) AS WStartDate,
                                                        MIN(WEndDate) AS WEndDate,
                                                        SUM(InSweetSpotDistance)
                                                        / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS SweetSpot,
                                                        SUM(FueledOverRPMDistance)
                                                        / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS OverRevWithFuel,
                                                        SUM(CruiseControlDistance)
                                                        / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS Cruise,
                                                        SUM(CoastInGearDistance)
                                                        / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS CoastInGear,
                                                        CAST(SUM(IdleTime) AS FLOAT)
                                                        / dbo.ZeroYieldNull(SUM(TotalTime)) AS Idle,
                                                        CAST(SUM(PTOMovingTime)
                                                        + SUM(PTONonMovingTime) AS FLOAT)
                                                        / dbo.ZeroYieldNull(SUM(TotalTime)) AS Pto,
                                                        ISNULL(SUM(EngineBrakeDistance) / dbo.ZeroYieldNull(SUM(ServiceBrakeDistance + EngineBrakeDistance)), 0) AS EngineServiceBrake,
                                                        ISNULL(SUM(EngineBrakeOverRPMDistance) / dbo.ZeroYieldNull(SUM(EngineBrakeDistance)), 0) AS OverRevWithoutFuel,
                                                        ISNULL(( SUM(ROPCount) * ( dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull(( SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000 ))) ) ), 0) AS Rop,
                                                        ISNULL(SUM(OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)), 0) AS OverSpeed,
                                                        ISNULL(( SUM(PanicStopCount) * ( dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull(( SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000 ))) ) ), 0) AS HarshBraking,
                                                        SUM(DrivingDistance
                                                            * 1000 * @distmult) AS TotalDrivingDistance,
                                                        ( CASE WHEN @fuelmult = 0.1 THEN ( CASE WHEN SUM(TotalFuel) = 0 THEN NULL
                                                                                                ELSE SUM(TotalFuel * ISNULL(FuelMultiplier, 1.0)) * 100
                                                                                           END ) / SUM(DrivingDistance + PTOMovingDistance)
                                                               ELSE ( SUM(DrivingDistance + PTOMovingDistance) * 1000 ) / ( CASE WHEN SUM(TotalFuel) = 0 THEN NULL
                                                                                                                                 ELSE SUM(TotalFuel * ISNULL(FuelMultiplier, 1.0))
                                                                                                                            END ) * @fuelmult
                                                          END ) AS FuelEcon
                                              FROM      dbo.Reporting
														INNER JOIN dbo.Vehicle v ON Reporting.VehicleIntId = v.VehicleIntId
														INNER JOIN dbo.Driver d ON Reporting.DriverIntId = d.DriverIntId
                                                        INNER JOIN @period_dates p ON Reporting.Date BETWEEN p.WStartDate
                                                                                                     AND     p.WEndDate
                                              WHERE     Date BETWEEN p.WStartDate AND p.WEndDate
                                                        AND v.VehicleId = @vid
                                                        AND p.WeekNumber = 0
                                              GROUP BY  d.DriverId,
                                                        v.VehicleId,
                                                        WeekNumber
                                                        WITH CUBE
                                              HAVING    SUM(DrivingDistance) > 10
                                            ) o
                                ) p
                                LEFT JOIN dbo.Vehicle v ON p.VehicleId = v.VehicleId
                                LEFT JOIN dbo.Driver d ON p.DriverId = d.DriverId
                    ) CubeResult
            WHERE   CubeResult.VehicleId = @vid
                    AND WeekNumber = 0
            UNION -- get prior 5 week period to calculate IsScoreBetter
            SELECT  *
            FROM    ( SELECT    v.VehicleId,
                                Registration,
                                d.DriverId,
                                d.Surname + ' ' + d.Firstname as DriverName,
                                99 AS WeekNumber,
                                NULL AS WStartDate,
                                NULL AS WEndDate,
                                Score,
                                IsScoreBetter,
                                TotalDrivingDistance,
                                SweetSpot,
                                Idle,
                                OverRevWithFuel,
                                Cruise,
                                EngineServiceBrake,
                                HarshBraking,
                                CoastInGear,
                                OverSpeed,
                                Rop,
                                OverRevWithoutFuel,
                                Pto,
                                FuelEcon,
                                @sdate AS sdate,
                                @edate AS edate,
                                @diststr AS DistanceUnit,
                                @fuelstr AS FuelUnit,
                                dbo.GYRColourConfig(Score, 18, @rprtcfgid) AS ScoreColour,
                                dbo.GYRColourConfig(SweetSpot * 100, 1,
                                                    @rprtcfgid) AS SweetSpotColour,
                                dbo.GYRColourConfig(Idle * 100, 6, @rprtcfgid) AS IdleColour,
                                dbo.GYRColourConfig(OverRevWithFuel * 100, 2,
                                                    @rprtcfgid) AS OverRevWithFuelColour,
                                dbo.GYRColourConfig(Cruise * 100, 4,
                                                    @rprtcfgid) AS CruiseColour,
                                dbo.GYRColourConfig(EngineServiceBrake * 100,
                                                    7, @rprtcfgid) AS EngineServiceBrakeColour,
                                dbo.GYRColourConfig(HarshBraking, 12,
                                                    @rprtcfgid) AS HarshBrakingColour,
                                dbo.GYRColourConfig(CoastInGear * 100, 5,
                                                    @rprtcfgid) AS CoastInGearColour
                      FROM      ( SELECT    *,
                                            Score = dbo.ScorePerformanceConfig(SweetSpot, OverRevWithFuel, NULL, Cruise, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, NULL, HarshBraking, NULL, @rprtcfgid),
                                            NULL AS IsScoreBetter
                                  FROM      ( SELECT    CASE WHEN ( GROUPING(v.VehicleId) = 1 )
                                                             THEN NULL
                                                             ELSE ISNULL(v.VehicleId, NULL)
                                                        END AS VehicleId,
                                                        CASE WHEN ( GROUPING(d.DriverId) = 1 )
                                                             THEN NULL
                                                             ELSE ISNULL(d.DriverId, NULL)
                                                        END AS DriverId,
                                                        SUM(InSweetSpotDistance)
                                                        / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS SweetSpot,
                                                        SUM(FueledOverRPMDistance)
                                                        / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS OverRevWithFuel,
                                                        SUM(CruiseControlDistance)
                                                        / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS Cruise,
                                                        SUM(CoastInGearDistance)
                                                        / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS CoastInGear,
                                                        CAST(SUM(IdleTime) AS FLOAT)
                                                        / dbo.ZeroYieldNull(SUM(TotalTime)) AS Idle,
                                                        CAST(SUM(PTOMovingTime)
                                                        + SUM(PTONonMovingTime) AS FLOAT)
                                                        / dbo.ZeroYieldNull(SUM(TotalTime)) AS Pto,
                                                        ISNULL(SUM(EngineBrakeDistance) / dbo.ZeroYieldNull(SUM(ServiceBrakeDistance + EngineBrakeDistance)), 0) AS EngineServiceBrake,
                                                        ISNULL(SUM(EngineBrakeOverRPMDistance) / dbo.ZeroYieldNull(SUM(EngineBrakeDistance)), 0) AS OverRevWithoutFuel,
                                                        ISNULL(( SUM(ROPCount) * ( dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull(( SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000 ))) ) ), 0) AS Rop,
                                                        ISNULL(SUM(OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)), 0) AS OverSpeed,
                                                        ISNULL(( SUM(PanicStopCount) * ( dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull(( SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000 ))) ) ), 0) AS HarshBraking,
                                                        SUM(DrivingDistance
                                                            * 1000 * @distmult) AS TotalDrivingDistance,
                                                        ( CASE WHEN @fuelmult = 0.1 THEN ( CASE WHEN SUM(TotalFuel) = 0 THEN NULL
                                                                                                ELSE SUM(TotalFuel * ISNULL(FuelMultiplier, 1.0)) * 100
                                                                                           END ) / SUM(DrivingDistance + PTOMovingDistance)
                                                               ELSE ( SUM(DrivingDistance + PTOMovingDistance) * 1000 ) / ( CASE WHEN SUM(TotalFuel) = 0 THEN NULL
                                                                                                                                 ELSE SUM(TotalFuel * ISNULL(FuelMultiplier, 1.0))
                                                                                                                            END ) * @fuelmult
                                                          END ) AS FuelEcon
                                              FROM      dbo.Reporting
															INNER JOIN dbo.Vehicle v ON Reporting.VehicleIntId = v.VehicleIntId
															INNER JOIN dbo.Driver d ON Reporting.DriverIntId = d.DriverIntId
                                              WHERE     Date BETWEEN DATEADD(dd, DATEDIFF(dd, @edate, @sdate) - 1, @sdate)
                                                             AND     DATEADD(dd, -1, @sdate)
                                                        AND v.VehicleId = @vid
                                              GROUP BY  d.DriverId,
                                                        v.VehicleId
                                                        WITH CUBE
                                              HAVING    SUM(DrivingDistance) > 10
                                            ) o
                                ) p
                                LEFT JOIN dbo.Vehicle v ON p.VehicleId = v.VehicleId
                                LEFT JOIN dbo.Driver d ON p.DriverId = d.DriverId
                    ) CubeResult
            WHERE   CubeResult.VehicleId = @vid
                    AND DriverId IS NULL

    SELECT  r1.DriverId AS DetailId,
            DetailName = CASE WHEN ( r1.DriverId IS NULL
                                     AND r1.WeekNumber IS NULL
                                   ) THEN r1.Registration
                              WHEN ( r1.DriverId IS NULL
                                     AND r1.WeekNumber IS NOT NULL
                                   )
                              THEN CONVERT(VARCHAR(6), [dbo].TZ_GetTime(r1.WStartDate, DEFAULT, @uid), 13)
                                   + ' - '
                                   + CONVERT(VARCHAR(6), [dbo].TZ_GetTime(r1.WEndDate, DEFAULT, @uid), 13)
                              ELSE r1.DriverName
                         END,
            r1.VehicleId AS EntityId,
            r1.Registration AS EntityName,
            r1.WeekNumber,
            r1.Score,
            IsScoreBetter = CASE WHEN r1.Score - r2.Score > 0 THEN 0
                                 WHEN r1.Score - r2.Score < 0 THEN 1
                                 ELSE NULL
                            END,
            r1.TotalDrivingDistance,
            r1.SweetSpot,
            r1.Idle,
            r1.OverRevWithFuel,
            r1.Cruise,
            r1.EngineServiceBrake,
            CEILING(r1.HarshBraking) AS HarshBraking,
            r1.CoastInGear,
            r1.OverSpeed,
            CEILING(r1.Rop) AS Rop,
            r1.OverRevWithoutFuel,
            r1.Pto,
            r1.FuelEcon,
            r1.sdate,
            r1.edate,
            r1.DistanceUnit,
            r1.FuelUnit,
            r1.ScoreColour,
            r1.SweetSpotColour,
            r1.IdleColour,
            r1.OverRevWithFuelColour,
            r1.CruiseColour,
            r1.EngineServiceBrakeColour,
            r1.HarshBrakingColour,
            r1.CoastInGearColour
    FROM    @ResultSet r1
            LEFT JOIN @ResultSet r2 ON ( r1.DriverId = r2.DriverId
                                         OR ( r1.DriverId IS NULL
                                              AND r2.DriverId IS NULL
                                            )
                                       )
                                       AND r1.vehicleid = r2.vehicleid
                                       AND ( ( r1.WeekNumber - r2.WeekNumber ) = 1
                                             OR r1.WeekNumber IS NULL
                                             AND r2.WeekNumber = 99
                                           )
    WHERE   r1.weeknumber IS NULL
            OR ( r1.weeknumber > 0
                 AND r1.WeekNumber < 99
               )
    ORDER BY r1.WeekNumber,
            r1.DriverName

GO
