SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportEfficiency_Custom]
(
	@vids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS

--DECLARE	@vids varchar(max),
--		@sdate datetime,
--		@edate datetime,
--		@expanddates bit,
--		@uid UNIQUEIDENTIFIER,
--		@rprtcfgid UNIQUEIDENTIFIER

----SET @vids = N'18A6474A-EFF8-48DB-B35B-D81D61CF7B6D,EAA62D7E-AFE3-4257-9C18-EFB96BF68040,44CE6C87-D818-4F4E-B57E-0C26B296996C,DA23F372-DAA2-4D48-B23D-4E654D143BDF,A841B922-41F5-46D1-9E5D-BCFF3BBA7D01,EAA62D7E-AFE3-4257-9C18-EFB96BF68040'
----SET @vids = N'883BBEFD-3402-4CF4-81E2-22170DE40A41,5BF54A2E-782E-4F22-8CE4-711F8107E6D1,71442A52-424A-411C-9914-C42F617D5611,9F3013DE-2FA3-4F4F-BCAE-FA412C3D5805'
------SET @vids = N'7E14776A-9E4E-4292-B2D8-D8B7FBB6C4DA,AB2C3E22-0410-4433-8402-762311453A4D,C09EB6AF-51CD-4A32-B857-BDEB38559AEE,30C927FE-875D-4D6D-A00C-F83DF77E7684,51F425E4-B358-4D10-B3B5-D194FE113088,EC61C110-72AE-49FC-88BB-AE9E204127E8,342D7864-32B9-45DF-B58F-A64675B3D88A,F836759E-7B18-44D1-9DA8-B8F77D5EEAEE,C968897D-7E0F-4150-8A87-DAFAA411FBFC,5B5387E3-E13B-4205-9055-7DC71363450F,AAE6CCE6-25BE-4FA8-B259-B884E767B41D,F099E121-86A8-4BF3-9D52-857F8FEDE333,C393FD63-27B5-4661-BAEA-67A156C1EF48,A3EFD230-3C47-4B01-94E4-886A00306DE0,971720BB-03EE-436B-89B2-7D94EDC4E735,10DDDD5C-8A3C-43C3-AACF-2C21BA9B5BD6,4F034C0D-5B7F-4800-A3B4-F263DFBF0913,6098F6A1-AA4F-4FBC-ADEE-6458A3B006AC,8B767A49-F234-4516-B3AE-1BFD3E25AF63,24F8CD60-BEB5-4CD7-9574-AFD763C7A3C9,41E30FFF-73C5-4A02-985E-3DC429B26E49,FFAFAD4E-FCF0-4916-80B9-79F8BCF1E7E9,0F226108-5CE9-45B4-88EE-D99CC37DD471,9412966E-61C5-40E3-9370-305FC4CBAA2E,16F1933B-39DF-4F0F-B5AB-E07338C6D49E,DFFA0D8B-3015-4FC8-9B1B-9FA7B27BEECE,C889693A-4636-4371-AD61-C70E4E40E3D6,D8098A7D-6023-4330-8593-B77CC5488119,A70F54C3-F27B-4FEC-AF34-7A3BEC246335,0D3FC172-EF33-4E8C-9F9A-FE7ACABB8EC1,62277415-6B05-4A40-A844-9307D9662D18,DCDDCA74-EFA8-4512-BCA6-D6B1F62F1C6A,C7F2BB3B-E861-4280-AA8A-65708D64345C,2F59FD06-BC21-43BA-AFCE-07D4F8E3CC3E,62F02E36-2728-4AF1-B1FE-CDB80FDD6EDD,5DA777C6-A56D-4EC2-A227-D45728FFB5EE,D190AE1D-AB10-4E42-AACC-A2F2CDD995F3,E25EE625-7580-4DC9-BDFC-658C9006D9B3,B7EC2A0E-DF83-448F-A7DC-B2DA66DA373F,95A8918D-C0E8-4DB9-A4D9-7D8DB4348A75,563D2842-595A-428F-805E-20A10DF190A4,1E523C0B-8594-4DDE-ADEC-5633395CB731'
------SET @vids = N'E6B47E39-A31E-4099-AF90-07E3AC9672A2,9CBACD09-0EFA-4893-83D8-0805CA5EA668,A2A2640B-9D8C-4394-9A0B-0C7314F1FEF8,8B791927-A40B-4DB0-94E3-13060C87B098,62A2D9E3-A8FB-4B1C-9D3D-1678B0ABD164,B2563533-AF00-4C22-93A6-28CEAE11EB16,CA3B8457-B828-4BEA-911B-369FAF0A0668,264EAE9D-0FFC-4EEC-BC41-3A7AF3EFFFC4,94D22F73-1BDF-48E1-BF70-3D3D7367CCE1,C39627D7-E68E-4345-8982-46FE94E92E1F,9957F5A3-DDDC-49FE-A565-5017560ABCC9,5C76D272-2C70-4D7E-9F0B-52BB44431A53,740481BD-B748-4E59-8F57-53C8D24AF66F,77787297-FDC2-4310-B55A-59D2CE556D92,452930A1-EBCB-4B5A-9B4D-5AD9FCC212DF,CA5DAE58-A65A-40F8-8508-5C955A00CEAA,D3BFDE89-ABED-4748-BC37-6AD2A5155ACA,E6EF363F-111D-45B5-8570-6DBF31D7D448,4C3F8B30-7441-4E11-BEFC-6EE321A56769,F2EEB24A-55C9-4761-8C3B-738E732FB2CC,1C7A100F-AE70-4A90-921F-763C4FB5656E,40285DFE-8CAA-46C7-BBF0-78899BA29B10,C36D89F9-D8ED-4C1A-81EC-7BBEFFB42F47,10BB3886-71CD-473E-9D3A-7C95488F66A4,B6259497-D7C2-4065-B10E-80B632B8FA93,E5319802-25EC-4956-8491-8511385DE525,F4DBA886-E1F3-43CE-87EB-898F2B1E4BB1,81890D1B-B801-4C23-92C8-8CCEAF196326,DB83CA34-002A-47D3-B8B8-8DF78FD3C8E3,9ADFCDBB-D7B2-4418-A04B-90D6C99EFC55,481A6746-A044-413C-A9D5-968283D4D6E4,A779297D-9574-4AA5-A42D-98FE1E21C577,D311B8A6-F705-448E-A92C-995B2BC57158,13F2699C-4823-48A0-8297-A5D26B1BD22D,861CB676-1178-44BA-808A-A61764388227,689FC032-4F36-474A-AB20-A6ADE94E7F6A,AB69614A-5E01-4317-BFDD-A9208E620A32,DDFBF418-902F-4012-90F4-AC3FD83D9B38,D1BCD01D-5DDC-4DD6-892D-ACA111CB5B8F,A76F890C-33D7-46DE-85A4-AE6486483748,17381833-3056-4E01-BEEF-B5A7E8D6E0B1,004C733E-8ACE-45D1-9B31-B69842B7CCA3,FF31B0A0-867F-4B15-96FA-B709AFA91611,1E6FAECF-6630-4E09-8BE0-C582AAA41F4B,76D67C4C-2F40-4071-8F2C-CAF23560A5A3,316E05A7-A25B-409F-BBBF-D45AAF52CA9A,43C3ECD5-080B-4999-9712-D8E385C6A92D,55DFECFF-FE7F-47D9-ADA8-D9A238625AF7,73426225-D281-489B-B91C-DE8EA13B620A,A1ABB1E0-2BEE-4A6F-83D0-DEFB641D30DF,7A18FB2E-DF0F-472E-B061-E1E30C58A396,94DB6752-E944-4EC9-B558-E2920B480E98,6F3BBD59-6BB9-4306-8E1F-E68815E19FBE,9C7F3354-6E32-41BF-BA29-E9FBD42F1964,2B17E92C-5499-472D-93A0-EA2AA2FC7270,0A8EAE1B-9CEB-4ACB-9E78-F4E5497D9A12,B02E79A4-08D4-40B7-A4A6-F93D0AA14D00,8A6D2235-A47E-43D8-B047-FB730F14AFF7,0DEEE6B4-2C03-4BE1-8C53-FD42CDAB40DA'

----SET @sdate = '2010-07-10 00:00'
----SET @edate = '2010-08-10 23:59'
----SET @uid = N'8AD60F3A-618E-4DC0-A5AB-C7ECB26BAB4C' 

--SET @vids = N'DD3BFBD1-17FF-4764-8FC0-B334EC0458C6,B4469487-6976-42A8-92EA-81FCAD483779'
--SET @sdate = '2010-09-12 00:00'
--SET @edate = '2010-10-12 23:59'
--SET @uid = N'4C0A0D44-0685-4292-9087-F32E03F10134' 
--SET @rprtcfgid = N'87F8B324-5C79-4C9C-93CF-164E8C9B5E1C'

DECLARE @lvids varchar(max),
		@lsdate datetime,
		@ledate datetime,
		@luid UNIQUEIDENTIFIER,
		@lrprtcfgid UNIQUEIDENTIFIER

SET @lvids = @vids
SET @lsdate = @sdate
SET @ledate = @edate
SET @luid = @uid
SET @lrprtcfgid = @rprtcfgid

DECLARE @vid UNIQUEIDENTIFIER,
		@did UNIQUEIDENTIFIER

DECLARE @diststr varchar(20),
		@distmult float,
		@fuelstr varchar(20),
		@fuelmult float,
		@co2str varchar(20),
		@co2mult float,
		@timezone varchar(255)

DECLARE @results TABLE
(
	VehicleId UNIQUEIDENTIFIER,
	DriverId UNIQUEIDENTIFIER,
	CreationCodeId INT,
	TotalCount INT
)

SELECT @timezone = dbo.UserPref(@luid, 600)

SET @lsdate = [dbo].TZ_ToUTC(@lsdate,@timezone,@luid)
SET @ledate = [dbo].TZ_ToUTC(@ledate,@timezone,@luid)


INSERT INTO @results (VehicleId, DriverId, CreationCodeId, TotalCount) 
SELECT v.VehicleId, d.DriverId, e.CreationCodeId, COUNT(e.CreationCodeId) 
FROM dbo.Event e 
	INNER JOIN dbo.Driver d ON e.DriverIntId = d.DriverIntId
	INNER JOIN dbo.CustomerDriver cd ON d.DriverId = cd.DriverId
	INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
	INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
	INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId AND cd.CustomerId = c.CustomerId
WHERE e.EventDateTime BETWEEN @lsdate AND @ledate 
	AND e.CreationCodeId IN (36,37,38) 
	AND e.Lat != 0 AND e.Long != 0 
	AND v.VehicleId IN (SELECT VALUE FROM dbo.Split(@lvids, ','))
GROUP BY v.VehicleId, d.DriverId, e.CreationCodeId, c.CustomerIntId

SELECT @diststr = [dbo].UserPref(@luid, 203)
SELECT @distmult = [dbo].UserPref(@luid, 202)
SELECT @fuelstr = [dbo].UserPref(@luid, 205)
SELECT @fuelmult = [dbo].UserPref(@luid, 204)
SELECT @co2str = [dbo].UserPref(@luid, 211)
SELECT @co2mult = [dbo].UserPref(@luid, 210)
          
-- reconvert CreationDateTime and ClosureDateTime for display purposes	
SELECT
		v.VehicleId,	
		Registration,
		d.DriverId,
 		dbo.FormatDriverNameByUser(d.DriverId, @luid) as DriverName,
		Number,
		SweetSpot, OverRevWithFuel, TopGear, Cruise, CoastInGear, Idle, TotalTime, 
		ServiceBrakeUsage, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, 
		CoastOutOfGear, HarshBraking, TotalDrivingDistance, FuelEcon, DriveFuelEcon,
		Pto,
		Co2, 			
		CruiseTopGearRatio,
		Acceleration,
		Braking,
		Cornering,
		
		Efficiency, Safety,
		
		@lsdate AS sdate,
		@ledate AS edate,
		[dbo].TZ_GetTime(@lsdate,default,@luid) AS CreationDateTime,
		[dbo].TZ_GetTime(@ledate,default,@luid) AS ClosureDateTime,

		@diststr AS DistanceUnit,
		@fuelstr AS FuelUnit,
		@co2str AS Co2Unit,

		dbo.GYRColourConfig(SweetSpot*100, 1, @lrprtcfgid) AS SweetSpotColour,
		dbo.GYRColourConfig(OverRevWithFuel*100, 2, @lrprtcfgid) AS OverRevWithFuelColour,
		dbo.GYRColourConfig(TopGear*100, 3, @lrprtcfgid) AS TopgearColour,
		dbo.GYRColourConfig(Cruise*100, 4, @lrprtcfgid) AS CruiseColour,
		dbo.GYRColourConfig(CoastInGear*100, 5, @lrprtcfgid) AS CoastInGearColour,		
		dbo.GYRColourConfig(Idle*100, 6, @lrprtcfgid) AS IdleColour,
		dbo.GYRColourConfig(EngineServiceBrake*100, 7, @lrprtcfgid) AS EngineServiceBrakeColour,
		dbo.GYRColourConfig(OverRevWithoutFuel*100, 8, @lrprtcfgid) AS OverRevWithoutFuelColour,
		dbo.GYRColourConfig(Rop, 9, @lrprtcfgid) AS RopColour,
		dbo.GYRColourConfig(OverSpeed*100, 10, @lrprtcfgid) AS TimeOverSpeedColour,
		dbo.GYRColourConfig(CoastOutOfGear*100, 11, @lrprtcfgid) AS TimeOutOfGearCoastingColour,
		dbo.GYRColourConfig(HarshBraking, 12, @lrprtcfgid) AS HarshBrakingColour,
		dbo.GYRColourConfig(FuelEcon, 16, @lrprtcfgid) AS KPLColour,
		dbo.GYRColourConfig(CruiseTopGearRatio*100, 25, @lrprtcfgid) AS CruiseTopGearRatioColour,
		dbo.GYRColourConfig(Acceleration, 22, @lrprtcfgid) AS AccelerationColour, 
		dbo.GYRColourConfig(Braking, 23, @lrprtcfgid) AS BrakingColour, 
		dbo.GYRColourConfig(Cornering, 24, @lrprtcfgid) AS CorneringColour,
		dbo.GYRColourConfig(Efficiency, 14, @lrprtcfgid) AS EfficiencyColour,
		dbo.GYRColourConfig(Safety, 15, @lrprtcfgid) AS SafetyColour

FROM
	(SELECT *,
		
		Efficiency = dbo.ScoreEfficiencyConfig(SweetSpot, OverRevWithFuel, TopGear, Cruise, Idle, CruiseTopGearRatio, @lrprtcfgid),
		Safety = dbo.ScoreSafetyConfig(CoastInGear, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, CoastOutOfGear, HarshBraking, Acceleration, Braking, Cornering, @lrprtcfgid)

	FROM
		(SELECT
			CASE WHEN (GROUPING(v.VehicleId) = 1) THEN NULL
				ELSE ISNULL(v.VehicleId, NULL)
			END AS VehicleId,

			CASE WHEN (GROUPING(d.DriverId) = 1) THEN NULL
				ELSE ISNULL(d.DriverId, NULL)
			END AS DriverId,

			SUM(InSweetSpotDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS SweetSpot,
			SUM(FueledOverRPMDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS OverRevWithFuel,
			SUM(TopGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS TopGear,
			SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS Cruise,
			SUM(CoastInGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS CoastInGear,
			SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance)) AS CruiseTopGearRatio,
			CAST(SUM(IdleTime) AS float) / dbo.ZeroYieldNull(SUM(TotalTime)) AS Idle,
			CAST(SUM(PTOMovingTime) + SUM(PTONonMovingTime) AS float) / dbo.ZeroYieldNull(SUM(TotalTime)) AS Pto,
			ISNULL((SUM(TotalFuel) * 2639.1 * @co2mult) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS Co2, --@co2mult: 1 for g/km, 1.6 for g/miles
			SUM(TotalTime) AS TotalTime,
			SUM(ServiceBrakeDistance) / CASE WHEN SUM(DrivingDistance + PTOMovingDistance) = 0 THEN NULL ELSE SUM(DrivingDistance + PTOMovingDistance) END AS ServiceBrakeUsage,
			ISNULL(SUM(EngineBrakeDistance) / dbo.ZeroYieldNull(SUM(ServiceBrakeDistance + EngineBrakeDistance)),0) AS EngineServiceBrake,
			ISNULL(SUM(EngineBrakeOverRPMDistance) / dbo.ZeroYieldNull(SUM(EngineBrakeDistance)),0) AS OverRevWithoutFuel,
			ISNULL((SUM(ROPCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS Rop,
			ISNULL(SUM(OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS OverSpeed,
			ISNULL(SUM(CoastOutOfGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS CoastOutOfGear,
			ISNULL((SUM(PanicStopCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS HarshBraking,
			SUM(DrivingDistance * 1000 * @distmult) /*/ COUNT(DISTINCT Vehicles.Registration)*/ AS TotalDrivingDistance,
			ISNULL((MAX(ra.TotalCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS Acceleration,
			ISNULL((MAX(rb.TotalCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS Braking,
			ISNULL((MAX(rc.TotalCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS Cornering,

			(CASE WHEN @fuelmult = 0.1 THEN
				(CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0))*100 END)/SUM(DrivingDistance + PTOMovingDistance) 
			ELSE
				(SUM(DrivingDistance + PTOMovingDistance) * 1000) / (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon,
			
			(CASE WHEN @fuelmult = 0.1 THEN
				(CASE WHEN SUM(DrivingFuel * ISNULL(FuelMultiplier,1.0))=0 THEN NULL ELSE SUM(DrivingFuel * ISNULL(FuelMultiplier,1.0))*100 END)/(SUM(DrivingDistance))
			ELSE
				(SUM(DrivingDistance) * 1000) / (CASE WHEN SUM(DrivingFuel * ISNULL(FuelMultiplier,1.0))=0 THEN NULL ELSE SUM(DrivingFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS DriveFuelEcon
				
		FROM 	dbo.Reporting
				INNER JOIN dbo.Vehicle v ON Reporting.VehicleIntId = v.VehicleIntId
				INNER JOIN dbo.Driver d ON Reporting.DriverIntId = d.DriverIntId
				LEFT JOIN @results rb ON v.VehicleId = rb.VehicleId and d.DriverId = rb.DriverId and rb.CreationCodeId = 36 
				LEFT JOIN @results ra ON v.VehicleId = ra.VehicleId and d.DriverId = ra.DriverId and ra.CreationCodeId = 37
				LEFT JOIN @results rc ON v.VehicleId = rc.VehicleId and d.DriverId = rc.DriverId and rc.CreationCodeId = 38

		WHERE
		    Date BETWEEN @lsdate AND @ledate 
		AND v.VehicleId IN (SELECT Value FROM dbo.Split(@lvids, ','))

		GROUP BY d.DriverId, v.VehicleId WITH CUBE
		HAVING SUM(DrivingDistance) > 10) o
	) p

LEFT JOIN dbo.Vehicle v ON p.VehicleId = v.VehicleId
LEFT JOIN dbo.Driver d ON p.DriverId = d.DriverId

ORDER BY Registration, d.Surname, d.Firstname


GO
