SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_PopulateReporting]
	@date SMALLDATETIME, @DriverId UNIQUEIDENTIFIER = NULL
AS
DECLARE @sdate DATETIME, @edate DATETIME

SET @sdate = CAST(YEAR(@date) AS varchar(4)) + '-' + CAST(dbo.LeadingZero(MONTH(@date),2) AS varchar(2)) + '-' + CAST(dbo.LeadingZero(DAY(@date),2) AS varchar(2)) + ' 00:00:00.000'
SET @edate = CAST(YEAR(@date) AS varchar(4)) + '-' + CAST(dbo.LeadingZero(MONTH(@date),2) AS varchar(2)) + '-' + CAST(dbo.LeadingZero(DAY(@date),2) AS varchar(2)) + ' 23:59:59.000'

INSERT INTO Reporting (VehicleIntId, DriverIntId, InSweetSpotDistance, FueledOverRPMDistance,
	TopGearDistance, CruiseControlDistance, CoastInGearDistance, IdleTime, TotalTime,
	EngineBrakeDistance, ServiceBrakeDistance, EngineBrakeOverRPMDistance, ROPCount, OverSpeedDistance,
	CoastOutOfGearDistance, PanicStopCount, TotalFuel, TimeNoID, TimeID,
	DrivingDistance, PTOMovingDistance, Date, Rows, DrivingFuel, DigitalInput2Count)

	SELECT Accum.VehicleIntId, Accum.DriverIntId,
		SUM(InSweetSpotDistance) AS InSweetSpotDistance,
		SUM(FueledOverRPMDistance) AS FueledOverRPMDistance,
		SUM(TopGearDistance) AS TopGearDistance,
		SUM(CruiseControlDistance) AS CruiseControlDistance,
		SUM(CoastInGearDistance) AS CoastInGearDistance,
		SUM(IdleTime) AS IdleTime,
		SUM(DrivingTime + IdleTime + ShortIdleTime) AS TotalTime,
		SUM(EngineBrakeDistance) AS EngineBrakeDistance,
		SUM(ServiceBrakeDistance) AS ServiceBrakeDistance,
		SUM(EngineBrakeOverRPMDistance) AS EngineBrakeOverRPMDistance,
		--CASE WHEN ROPEnabled=1 THEN dbo.ROPCountDriverVehicle(Event.VehicleId, Event.CustomerIntId, NULL, NULL, Event.DriverId, @sdate, @edate, GETDATE(), 0) ELSE 0 END AS ROPCount,
		--dbo.ROPCountDriverVehicle(Event.VehicleId, Event.CustomerIntId, NULL, NULL, Event.DriverId, @sdate, @edate, GETDATE(), 0) AS ROPCount,
		0 AS ROPCount,
		SUM(OverSpeedDistance) AS OverSpeedDistance,
		SUM(CoastOutOfGearDistance) AS CoastOutOfGearDistance,
		SUM(PanicStopCount) AS PanicStopCount,
		SUM(DrivingFuel + PTONonMovingFuel + PTOMovingFuel + IdleFuel + ShortIdleFuel) AS TotalFuel,
		SUM(	CASE WHEN Driver.Number = 'No ID' OR Driver.Surname = 'UNKNOWN' THEN 0
			ELSE CAST(DrivingTime + PTOMovingTime + PTONonMovingTime + IdleTime + ShortIdleTime AS float) END) AS TimeNoID,
		SUM(CAST(DrivingTime + PTOMovingTime + PTONonMovingTime + IdleTime + ShortIdleTime AS float)) AS TimeID,
		SUM(DrivingDistance) AS DrivingDistance,
		SUM(PTOMovingDistance) AS PTOMovingDistance,
		@sdate AS Date,
		COUNT(*) AS Rows,
		SUM(DrivingFuel) AS DrivingFuel,
		SUM(DigitalInput2Count) as DigitalInput2Count

	FROM Accum
		INNER JOIN Driver ON Accum.DriverIntId = Driver.DriverIntId
		--INNER JOIN Vehicle ON Event.VehicleId = Vehicle.VehicleId

	WHERE CreationDateTime BETWEEN @sdate AND @edate
		AND (@DriverId IS NULL OR Accum.DriverIntId = dbo.GetDriverIntFromId(@DriverId))
		--AND Vehicle.Archived = 0
		--AND Event.CustomerIntId <> 0
		AND Accum.CustomerIntId <> 0

	GROUP BY Accum.CustomerIntId, Accum.VehicleIntId, Accum.DriverIntId, Accum.RouteID--, Vehicle.ROPEnabled

	OPTION (OPTIMIZE FOR (@sdate='2007-02-01',@edate='2007-02-02'))

GO
