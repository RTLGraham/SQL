SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Reporting_GetByVehicleIDsAndTime]
(
	@VehicleIDs NVARCHAR(MAX),
	@StartDate DATETIME,
	@EndDate DATETIME,
	@uid UNIQUEIDENTIFIER
)
AS

--debug
--DECLARE @VehicleIDs NVARCHAR(MAX)
--DECLARE	@StartDate DATETIME
--DECLARE	@EndDate DATETIME
--DECLARE @uid UNIQUEIDENTIFIER

--SET @StartDate = '2010-05-01 00:00'
--SET @EndDate = '2010-06-01 00:00'
--SET @VehicleIDs = '18A6474A-EFF8-48DB-B35B-D81D61CF7B6D,EAA62D7E-AFE3-4257-9C18-EFB96BF68040,44CE6C87-D818-4F4E-B57E-0C26B296996C,DA23F372-DAA2-4D48-B23D-4E654D143BDF,A841B922-41F5-46D1-9E5D-BCFF3BBA7D01,EAA62D7E-AFE3-4257-9C18-EFB96BF68040'
--SET @uid = N'8AD60F3A-618E-4DC0-A5AB-C7ECB26BAB4C'

--DECLARE @diststr varchar(20),
--		@distmult float,
--		@fuelstr varchar(20),
--		@fuelmult float

--SELECT @diststr = [dbo].UserPref(@uid, 203)
--SELECT @distmult = [dbo].UserPref(@uid, 202)
--SELECT @fuelstr = [dbo].UserPref(@uid, 205)
--SELECT @fuelmult = [dbo].UserPref(@uid, 204)

	SELECT  ReportingId,
			dbo.GetVehicleIdFromInt(VehicleIntId),
			dbo.GetDriverIdFromInt(DriverIntId),
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
			DrivingDistance,
			PTOMovingDistance,
			[Date],
			DrivingFuel,
			PTOMovingTime,
			PTOMovingFuel,
			PTONonMovingTime,
			PTONonMovingFuel,
			Safety = 
					-(	(	dbo.[IndDiff](7, dbo.[IndPercent](7, ISNULL(EngineBrakeDistance / dbo.ZeroYieldNull(ServiceBrakeDistance + EngineBrakeDistance),0)) ) * dbo.[IndWeight](7)
							+ dbo.[IndDiff](8, dbo.[IndPercent](8, ISNULL(EngineBrakeOverRPMDistance / dbo.ZeroYieldNull(EngineBrakeDistance),0)) ) * dbo.[IndWeight](8)
							+ dbo.[IndDiff](9, dbo.[IndPercent](9, Round(ISNULL((CAST(ROPCount AS float) / dbo.ZeroYieldNull((DrivingDistance /* * @distmult */)) /* * 1000 */),0),3)) ) * dbo.[IndWeight](9)
							+ dbo.[IndDiff](10, dbo.[IndPercent](10, ISNULL(OverSpeedDistance / dbo.ZeroYieldNull(DrivingDistance + PTOMovingDistance),0)) ) * dbo.[IndWeight](10)
							+ dbo.[IndDiff](11, dbo.[IndPercent](11, ISNULL(CoastOutOfGearDistance / dbo.ZeroYieldNull(DrivingDistance + PTOMovingDistance),0)) ) * dbo.[IndWeight](11)
							+ dbo.[IndDiff](12, dbo.[IndPercent](12, ISNULL((PanicStopCount / dbo.ZeroYieldNull((DrivingDistance /* * @distmult */)) /* * 1000 */),0)) ) * dbo.[IndWeight](12)
							-
							(SELECT SUM(dbo.[IndDiff](IndicatorId, CAST([Min] AS float)) * CAST([Weight] AS float)) /100 FROM dbo.ReportIndicator WHERE IndicatorId IN (SELECT Value FROM dbo.[Split]('7,8,9,10,11,12', ',')))
						) / (SELECT SUM(dbo.[IndDiff](IndicatorId, CAST([Min] AS float)) * CAST([Weight] AS float)) /100 FROM dbo.ReportIndicator WHERE IndicatorId IN (SELECT Value FROM dbo.[Split]('7,8,9,10,11,12', ',')))
					) * 100,
			Efficiency =
					-(	(	dbo.[IndDiff](1, dbo.[IndPercent](1, InSweetSpotDistance / dbo.ZeroYieldNull(DrivingDistance + PTOMovingDistance) ) ) * dbo.[IndWeight](1)
							+ dbo.[IndDiff](2, dbo.[IndPercent](2, FueledOverRPMDistance / dbo.ZeroYieldNull(DrivingDistance + PTOMovingDistance) ) ) * dbo.[IndWeight](2)
							+ dbo.[IndDiff](3, dbo.[IndPercent](3, TopGearDistance / dbo.ZeroYieldNull(DrivingDistance + PTOMovingDistance) ) ) * dbo.[IndWeight](3)
							+ dbo.[IndDiff](4, dbo.[IndPercent](4, CruiseControlDistance / dbo.ZeroYieldNull(DrivingDistance + PTOMovingDistance) ) ) * dbo.[IndWeight](4)
							+ dbo.[IndDiff](5, dbo.[IndPercent](5, CoastInGearDistance / dbo.ZeroYieldNull(DrivingDistance + PTOMovingDistance) ) ) * dbo.[IndWeight](5)
							+ dbo.[IndDiff](6, dbo.[IndPercent](6, CAST(IdleTime AS float) / dbo.ZeroYieldNull(TotalTime) ) ) * dbo.[IndWeight](6)
							-
							(SELECT SUM(dbo.[IndDiff](IndicatorId, CAST([IndicatorMin] AS float)) * CAST([IndicatorWeight] AS float)) /100 FROM dbo.ReportIndicator WHERE IndicatorId IN (SELECT Value FROM dbo.[Split]('1,2,3,4,5,6', ',')))
						) / (SELECT SUM(dbo.[IndDiff](IndicatorId, CAST([IndicatorMin] AS float)) * CAST([IndicatorWeight] AS float)) /100 FROM dbo.ReportIndicator WHERE IndicatorId IN (SELECT Value FROM dbo.[Split]('1,2,3,4,5,6', ',')))
					) * 100

	FROM    [dbo].[Reporting]
	WHERE   [Date] BETWEEN @StartDate AND @EndDate
			AND dbo.GetVehicleIdFromInt(VehicleIntId) IN (
				SELECT  Value
				FROM    dbo.[Split](@VehicleIDs, ',') )
			AND DrivingDistance > 5
--	ORDER BY [VehicleIntId]

GO
