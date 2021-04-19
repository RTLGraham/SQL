SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[proc_ReportEfficiencyVehicleScore]
    @vids VARCHAR(MAX) = NULL,
    @depid INT = NULL,
    @sdate DATETIME = NULL,
    @edate DATETIME = NULL,
    @expanddates BIT = 1,
    @uid UNIQUEIDENTIFIER = NULL
AS --DECLARE	@vids varchar(max),
--		@depid int,
--		@sdate datetime,
--		@edate datetime,
--		@expanddates bit,
--		@uid uniqueidentifier

--SET @vids = N'39C6BE26-6675-DF11-85AD-0015173D1551'
--SET @sdate = '2010-06-01 00:00:00'
--SET @edate = '2010-06-13 23:59:59'
--SET @uid = N'F2399FB5-2DEA-498C-9773-7F6649615CC2'

    SELECT  @depid = dbo.GetDepotId(@vids, @edate)

    DECLARE @diststr VARCHAR(20),
        @distmult FLOAT,
        @fuelstr VARCHAR(20),
        @fuelmult FLOAT

    SELECT  @diststr = [dbo].UserPref(@uid, 203)
    SELECT  @distmult = [dbo].UserPref(@uid, 202)
    SELECT  @fuelstr = [dbo].UserPref(@uid, 205)
    SELECT  @fuelmult = [dbo].UserPref(@uid, 204)

    SET @sdate = [dbo].TZ_GetTime(@sdate, DEFAULT, @uid)
    SET @edate = [dbo].TZ_GetTime(@edate, DEFAULT, @uid)

-- reconvert CreationDateTime and ClosureDateTime for display purposes
    SELECT  *,
            @sdate AS sdate,
            @edate AS edate,
            [dbo].TZ_GetTime(@sdate, DEFAULT, @uid) AS CreationDateTime,
            [dbo].TZ_GetTime(@edate, DEFAULT, @uid) AS ClosureDateTime,
            @diststr AS DistanceUnit,
            @fuelstr AS FuelUnit,
            dbo.GYRColour(Idle * 100, 6, DepotId) AS IdleColour,
            dbo.GYRColour(SweetSpot * 100, 1, DepotId) AS SweetSpotColour,
            dbo.GYRColour(OverRevWithFuel * 100, 2, DepotId) AS OverRevWithFuelColour,
            dbo.GYRColour(TopGear * 100, 3, DepotId) AS TopgearColour,
            dbo.GYRColour(Cruise * 100, 4, DepotId) AS CruiseColour,
            dbo.GYRColour(FuelEcon, 16, DepotId) AS KPLColour,
            dbo.GYRColour(Efficiency, 14, DepotId) AS EfficiencyColour,
            dbo.GYRColour(Safety, 15, DepotId) AS SafetyColour,
            dbo.GYRColour(EngineServiceBrake * 100, 7, DepotId) AS EngineServiceBrakeColour,
            dbo.GYRColour(OverRevWithoutFuel * 100, 8, DepotId) AS OverRevWithoutFuelColour,
            dbo.GYRColour(Rop, 9, DepotId) AS RopColour,
            dbo.GYRColour(OverSpeed * 100, 10, DepotId) AS TimeOverSpeedColour,
            dbo.GYRColour(CoastOutOfGear * 100, 11, DepotId) AS TimeOutOfGearCoastingColour,
            dbo.GYRColour(HarshBraking, 12, DepotId) AS HarshBrakingColour
    FROM    ( SELECT    *,
                        ( SELECT    TOP 1 Name
                          FROM      dbo.Indicator
                          WHERE     IndicatorId = 1
                        ) AS SweetSpotName,
                        ( SELECT    TOP 1 Name
                          FROM      dbo.Indicator
                          WHERE     IndicatorId = 2
                        ) AS OverRevWithFuelName,
                        ( SELECT    TOP 1 Name
                          FROM      dbo.Indicator
                          WHERE     IndicatorId = 3
                        ) AS TopGearName,
                        ( SELECT    TOP 1 Name
                          FROM      dbo.Indicator
                          WHERE     IndicatorId = 4
                        ) AS CruiseName,
                        ( SELECT    TOP 1 Name
                          FROM      dbo.Indicator
                          WHERE     IndicatorId = 6
                        ) AS IdleName,
                        ( SELECT    TOP 1 Name
                          FROM      dbo.Indicator
                          WHERE     IndicatorId = 10
                        ) AS OverSpeedName,
                        ( SELECT    TOP 1 Name
                          FROM      dbo.Indicator
                          WHERE     IndicatorId = 11
                        ) AS OutOfGearCoastingName,
                        ( SELECT    TOP 1 Name
                          FROM      dbo.Indicator
                          WHERE     IndicatorId = 12
                        ) AS HarshBrakingName,
                        Efficiency = -( ( dbo.IndDiff(1,
                                                      dbo.IndPercent(1, SweetSpot))
                                          * dbo.IndWeight(1) + dbo.IndDiff(2, dbo.IndPercent(2, OverRevWithFuel))
                                          * dbo.IndWeight(2) + dbo.IndDiff(3, dbo.IndPercent(3, TopGear))
                                          * dbo.IndWeight(3) + dbo.IndDiff(4, dbo.IndPercent(4, Cruise))
                                          * dbo.IndWeight(4) + dbo.IndDiff(5, dbo.IndPercent(5, CoastInGear))
                                          * dbo.IndWeight(5) + dbo.IndDiff(6, dbo.IndPercent(6, Idle))
                                          * dbo.IndWeight(6)
                                          - ( SELECT    SUM(dbo.IndDiff(IndicatorId, CAST([Min] AS FLOAT))
                                                            * CAST([Weight] AS FLOAT))
                                                        / 100
                                              FROM      dbo.IndicatorConfig
                                              WHERE     ReportConfigurationId IS NULL AND IndicatorId IN (
                                                        SELECT  Value
                                                        FROM    dbo.Split('1,2,3,4,5,6', ',') )
                                            ) )
                                        / ( SELECT  SUM(dbo.IndDiff(IndicatorId, CAST([Min] AS FLOAT))
                                                        * CAST([Weight] AS FLOAT))
                                                    / 100
                                            FROM    dbo.IndicatorConfig
													WHERE     ReportConfigurationId IS NULL AND IndicatorId IN (
                                                    SELECT  Value
                                                    FROM    dbo.Split('1,2,3,4,5,6', ',') )
                                          ) ) * 100,
                        Safety = -( ( dbo.IndDiff(7,
                                                  dbo.IndPercent(7, EngineServiceBrake))
                                      * dbo.IndWeight(7) + dbo.IndDiff(8, dbo.IndPercent(8, OverRevWithoutFuel))
                                      * dbo.IndWeight(8) + dbo.IndDiff(9, dbo.IndPercent(9, Rop))
                                      * dbo.IndWeight(9) + dbo.IndDiff(10, dbo.IndPercent(10, OverSpeed))
                                      * dbo.IndWeight(10) + dbo.IndDiff(11, dbo.IndPercent(11, CoastOutOfGear))
                                      * dbo.IndWeight(11) + dbo.IndDiff(12, dbo.IndPercent(12, HarshBraking))
                                      * dbo.IndWeight(12)
                                      - ( SELECT    SUM(dbo.IndDiff(IndicatorId, CAST([Min] AS FLOAT))
                                                        * CAST([Weight] AS FLOAT))
                                                    / 100
                                          FROM      dbo.IndicatorConfig
                                              WHERE     ReportConfigurationId IS NULL AND IndicatorId IN (
                                                    SELECT  Value
                                                    FROM    dbo.Split('7,8,9,10,11,12', ',') )
                                        ) )
                                    / ( SELECT  SUM(dbo.IndDiff(IndicatorId, CAST([Min] AS FLOAT))
                                                    * CAST([Weight] AS FLOAT))
                                                / 100
                                        FROM    dbo.IndicatorConfig
                                              WHERE     ReportConfigurationId IS NULL AND IndicatorId IN (
                                                SELECT  Value
                                                FROM    dbo.Split('7,8,9,10,11,12', ',') )
                                      ) ) * 100
              FROM      ( SELECT    c.Name AS DepotName,
                                    c.CustomerIntId AS DepotId,
                                    v.Registration AS Identifier,
                                    v.VehicleId AS InternalID,
                                    SUM(InSweetSpotDistance)
                                    / dbo.ZeroYieldNull(SUM(DrivingDistance
                                                            + PTOMovingDistance)) AS SweetSpot,
                                    SUM(FueledOverRPMDistance)
                                    / dbo.ZeroYieldNull(SUM(DrivingDistance
                                                            + PTOMovingDistance)) AS OverRevWithFuel,
                                    SUM(TopGearDistance)
                                    / dbo.ZeroYieldNull(SUM(DrivingDistance
                                                            + PTOMovingDistance)) AS TopGear,
                                    SUM(CruiseControlDistance)
                                    / dbo.ZeroYieldNull(SUM(DrivingDistance
                                                            + PTOMovingDistance)) AS Cruise,
                                    SUM(CoastInGearDistance)
                                    / dbo.ZeroYieldNull(SUM(DrivingDistance
                                                            + PTOMovingDistance)) AS CoastInGear,
                                    CAST(SUM(IdleTime) AS FLOAT)
                                    / dbo.ZeroYieldNull(SUM(TotalTime)) AS Idle,
                                    ISNULL(SUM(EngineBrakeDistance)
                                           / dbo.ZeroYieldNull(SUM(ServiceBrakeDistance + EngineBrakeDistance)),
                                           0) AS EngineServiceBrake,
                                    ISNULL(SUM(EngineBrakeOverRPMDistance)
                                           / dbo.ZeroYieldNull(SUM(EngineBrakeDistance)),
                                           0) AS OverRevWithoutFuel,
                                    ROUND(ISNULL(( CAST(SUM(ROPCount) AS FLOAT)
                                                   / dbo.ZeroYieldNull(( SUM(DrivingDistance) * 0.6213999 ))
                                                   * 1000 ), 0), 3) AS Rop,
                                    ISNULL(SUM(OverSpeedDistance)
                                           / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),
                                           0) AS OverSpeed,
                                    ISNULL(SUM(CoastOutOfGearDistance)
                                           / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),
                                           0) AS CoastOutOfGear,
                                    ISNULL(( SUM(PanicStopCount)
                                             / dbo.ZeroYieldNull(( SUM(DrivingDistance) * 0.6213999 ))
                                             * 1000 ), 0) AS HarshBraking,
                                    SUM(DrivingDistance * 1000 * @distmult)
                                    / COUNT(DISTINCT v.Registration) AS TotalDrivingDistance,
                                    ( CASE WHEN @fuelstr = 'l/100km'
                                           THEN ( CASE WHEN SUM(TotalFuel) = 0
                                                       THEN NULL
                                                       ELSE SUM(TotalFuel * ISNULL(FuelMultiplier, 1.0))
                                                            * 100
                                                  END ) / SUM(DrivingDistance + PTOMovingDistance)
                                           ELSE ( SUM(DrivingDistance
                                                      + PTOMovingDistance)
                                                  * 1000 )
                                                / ( CASE WHEN SUM(TotalFuel) = 0
                                                         THEN NULL
                                                         ELSE SUM(TotalFuel * ISNULL(FuelMultiplier, 1.0))
                                                    END ) * @fuelmult
                                      END ) AS FuelEcon
                          FROM      dbo.Reporting
									INNER JOIN dbo.Vehicle v ON Reporting.VehicleIntId = v.VehicleIntId
                                    INNER JOIN dbo.CustomerVehicle ON v.VehicleId = CustomerVehicle.VehicleId
                                    INNER JOIN dbo.Customer c ON CustomerVehicle.CustomerId = c.CustomerId
                          WHERE     c.CustomerIntId = @depid
                                    AND ( GETDATE() BETWEEN ISNULL(StartDate, GETDATE())
                                                    AND     ISNULL(EndDate, GETDATE()) )
                                    AND Date BETWEEN @sdate AND @edate
                                    AND ( v.VehicleId IN (
                                          SELECT    Value
                                          FROM      dbo.Split(@vids, ',') ) )
		--AND TotalFuel>0
                          GROUP BY  c.Name,
                                    c.CustomerIntId,
                                    v.Registration,
                                    v.VehicleId
                          HAVING    SUM(DrivingDistance) > 5
                        ) o
            ) p
    ORDER BY Efficiency DESC
























GO
