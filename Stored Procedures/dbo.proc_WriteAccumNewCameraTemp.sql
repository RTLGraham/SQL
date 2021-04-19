SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_WriteAccumNewCameraTemp] 
	@aid bigint=NULL OUTPUT,
	
	@cameraNumber varchar(50), 

	@creationcid smallint, 
	@creationdt datetime, 
	@creationlat float, 
	@creationlong float,
	
	@closurecid smallint, 
	@closuredt datetime, 
	@closurelat float, 
	@closurelong float,
	
	
	@d_t int, @d_d float, @d_f FLOAT = 0.0,
	@si_t INT = 0, @si_f FLOAT = 0.0,
	@i_t int = 0, @i_f float = 0.0,

	
	@totalenginehours FLOAT = 0.0, @totalvehicledist float, @totalvehiclefuel FLOAT = 0.0,

	
	@dld_t INT = 0, --Data Link Downtime
	@SeqNumber INT = NULL,
	@StatusFlags INT = NULL
AS

	DECLARE @routenumber varchar(32),
			@ptonm_t int, 
			@ptonm_f float,
			@ptom_t int, 
			@ptom_d float, 
			@ptom_f float,
			@crc_t int, 
			@crc_d float, 
			@crc_f float,
			@rsg_t int, 
			@rsg_d float, 
			@rsg_f float,
			@tg_t int, 
			@tg_d float, 
			@tg_f float,
			@gd_t int, 
			@gd_d float, 
			@gd_f float,
			@coog_t int, 
			@coog_d float, 
			@coog_c smallint,
			@cig_t int, 
			@cig_d float, 
			@cig_f float,
			@bss_t int, 
			@bss_d float, 
			@bss_f float,
			@iss_t int, 
			@iss_d float, 
			@iss_f float,
			@ass_t int, 
			@ass_d float, 
			@ass_f float,
			@os_t int, 
			@os_d float, 
			@os_f float,
			@forpm_t int, 
			@forpm_d float, 
			@forpm_f float,
			@eborpm_t int, 
			@eborpm_d float,
			@aerpm SMALLINT=NULL, 
			@aerpmwd SMALLINT=NULL,
			@sb_t int, 
			@sb_d float, 
			@sb_c smallint,
			@eb_t int, 
			@eb_d float, 
			@eb_c smallint,
			@MaxRPM SMALLINT=NULL, 
			@MaxRPMTS datetime, 
			@MaxRPMLt float, 
			@MaxRPMLg float,
			@MaxRoadSpeedT int, 
			@MaxRoadSpeedD float, 
			@MaxRoadSpeedF float, 
			@MaxRoadSp smallint, 
			@MaxRoadSpeedTS datetime, 
			@MaxRoadSpeedLt float, 
			@MaxRoadSpeedLg float,
			@LongestCoastOutofgearT int, 
			@LongestCoastOutofgearTimeD float, 
			@LongestCoastOutofgearTimeTS datetime, 
			@LongestCoastOutofgearTimeLt float, 
			@LongestCoastOutofgearTimeLg float,
			@LongestIdleT int, @LongestIdleF float, 
			@LongestIdleTS datetime, 
			@LongestIdleLt float, 
			@LongestIdleLg float,
			@panicstopcount smallint,
			@EngineTempMidT int, 
			@EngineTempHighT int, 
			@MaxEngineCoolantTemp smallint,	
			@ael float, 
			@DataVal varchar(50), 
			@OverSpeedHighT int, 
			@OverSpeedHighD float, 
			@OverSpeedHighF float,
			@di1c smallint, 
			@di1at int,
			@di2c smallint, 
			@di2at int,
			@cael float, 
			@rael float, 
			@tael float, 
			@gael float,
			@AverageWeight int,
			@EngineLoad0Time int, 
			@EngineLoad0Distance float, 
			@EngineLoad0Fuel float,
			@EngineLoad100Time int, 
			@EngineLoad100Distance float, 
			@EngineLoad100Fuel float,
			@DriveFuelWhole int, 
			@DriveFuelFrac int,
			@ORCount INT,
			@CTGTime INT = NULL,
			@CTGDistance FLOAT = NULL,
			@CTGFuel FLOAT = NULL,
			@CNGDTime INT = NULL,
			@CNGDDistance FLOAT = NULL,
			@CNGDFuel FLOAT = NULL,
			@CSTime INT = NULL,
			@CSDistance FLOAT = NULL,
			@CSFuel FLOAT = NULL,
			@TGSTime INT = NULL,
			@TGSDistance FLOAT = NULL,
			@TGSFuel FLOAT = NULL,
			@OSTTime INT = NULL,
			@OSTSDistance FLOAT = NULL,
			@OSTSFuel FLOAT = NULL


	SELECT	@routenumber = NULL,
			@ptonm_t = 0,
			@ptonm_f = 0,
			@ptom_t = 0,
			@ptom_d = 0,
			@ptom_f = 0,
			@crc_t = 0,
			@crc_d = 0,
			@crc_f = 0,
			@rsg_t = 0,
			@rsg_d = 0,
			@rsg_f = 0,
			@tg_t = 0,
			@tg_d = 0,
			@tg_f = 0,
			@gd_t = 0,
			@gd_d = 0,
			@gd_f = 0,
			@coog_t = 0,
			@coog_d = 0,
			@coog_c = 0,
			@cig_t = 0,
			@cig_d = 0,
			@cig_f = 0,
			@bss_t = 0,
			@bss_d = 0,
			@bss_f = 0,
			@iss_t = 0,
			@iss_d = 0,
			@iss_f = 0,
			@ass_t = 0,
			@ass_d = 0,
			@ass_f = 0,
			@os_t = 0,
			@os_d = 0,
			@os_f = 0,
			@forpm_t = 0,
			@forpm_d = 0,
			@forpm_f = 0,
			@eborpm_t = 0,
			@eborpm_d = 0,
			@aerpm = 0, 
			@aerpmwd = 0,
			@sb_t = 0,
			@sb_d = 0,
			@sb_c = 0,
			@eb_t = 0,
			@eb_d = 0,
			@eb_c = 0,
			@MaxRPM = 0, 
			@MaxRPMTS = 0,
			@MaxRPMLt = 0,
			@MaxRPMLg = 0,
			@MaxRoadSpeedT = 0,
			@MaxRoadSpeedD = 0,
			@MaxRoadSpeedF = 0,
			@MaxRoadSp = 0,
			@MaxRoadSpeedTS = 0,
			@MaxRoadSpeedLt = 0,
			@MaxRoadSpeedLg = 0,
			@LongestCoastOutofgearT = 0,
			@LongestCoastOutofgearTimeD = 0,
			@LongestCoastOutofgearTimeTS = 0,
			@LongestCoastOutofgearTimeLt = 0,
			@LongestCoastOutofgearTimeLg = 0,
			@LongestIdleT = 0,
			@LongestIdleF = 0,
			@LongestIdleTS = 0,
			@LongestIdleLt = 0,
			@LongestIdleLg = 0,
			@panicstopcount = 0,
			@EngineTempMidT = 0,
			@EngineTempHighT = 0,
			@MaxEngineCoolantTemp = 0,
			@ael = 0,
			@DataVal = 'CFFFFFFF', 
			@OverSpeedHighT = 0,
			@OverSpeedHighD = 0,
			@OverSpeedHighF = 0,
			@di1c = 0,
			@di1at = 0,
			@di2c = 0,
			@di2at = 0,
			@cael = 0,
			@rael = 0,
			@tael = 0,
			@gael = 0,
			@AverageWeight = 0,
			@EngineLoad0Time = 0,
			@EngineLoad0Distance = 0,
			@EngineLoad0Fuel = 0,
			@EngineLoad100Time = 0,
			@EngineLoad100Distance = 0,
			@EngineLoad100Fuel = 0,
			@DriveFuelWhole = 0,
			@DriveFuelFrac = 0,
			@ORCount = 0,
			@CTGTime = 0,
			@CTGDistance = 0,
			@CTGFuel = 0,
			@CNGDTime = 0,
			@CNGDDistance = 0,
			@CNGDFuel = 0,
			@CSTime = 0,
			@CSDistance = 0,
			@CSFuel = 0,
			@TGSTime = 0,
			@TGSDistance = 0,
			@TGSFuel = 0,
			@OSTTime = 0,
			@OSTSDistance = 0,
			@OSTSFuel = 0

	-- need to look up 
	--	CustomerIntId, VehicleIntId, DriverIntId, RouteID,
	DECLARE @customerintid INT, @vintid INT, @ivhintid INT, @dintid INT, @rid INT
	DECLARE @customerid UNIQUEIDENTIFIER, @vid UNIQUEIDENTIFIER, @did UNIQUEIDENTIFIER, @ivh UNIQUEIDENTIFIER
	DECLARE @driverid varchar(32)

	SET @vintid = NULL
	SET @dintid = NULL
	SET @ivhintid = NULL
	SET @customerintid = NULL
	SET @customerid = NULL
	SET @rid = NULL
	SET @vid = NULL
	SET @did = NULL
	SET @driverid = NULL
	SET @routenumber = 'No Route'

	-- Code below taken from proc_WriteAccumNewTemp() with some select columns removed
	SELECT	@vintid = v.VehicleIntId,
			@vid = v.VehicleId,
			@ivh = i.IVHId,
			@customerintid = cust.CustomerIntId,
			@customerid = cust.CustomerId
	FROM    Vehicle v
			LEFT JOIN dbo.IVH i ON i.IVHId = v.IVHId AND i.Archived = 0
			INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId AND cv.Archived = 0 AND cv.EndDate IS NULL
			INNER JOIN dbo.Customer cust ON cust.CustomerId = cv.CustomerId
			INNER JOIN dbo.VehicleCamera vc ON vc.VehicleId = v.VehicleId AND vc.Archived = 0 AND vc.EndDate IS NULL
			INNER JOIN dbo.Camera c ON c.CameraId = vc.CameraId AND c.Archived = 0
	WHERE   v.archived = 0
			AND c.archived = 0
			AND c.Serial = @cameraNumber

	--Check for the linked driver
	SET @did = dbo.GetLinkedDriverId(@vid)

	-- Set default driver if none linked
	IF @driverID = '' OR @driverID IS NULL
	BEGIN
		SET @driverid = 'No ID'
		SET @did = dbo.GetDriverIdFromNumberAndCustomer(@driverid, @customerid)
		SET @dintid = dbo.GetDriverIntFromId(@did)
	END

	--Write Route
	SET @rid = dbo.GetRouteIdFromNumberAndCustomer(@routenumber, @customerid)
	IF @rid IS NULL -- route not found so create one
		EXEC proc_WriteRoute @rid OUTPUT, @customerid, @routenumber, 'UNKNOWN'


	IF @ivh IS NULL
	BEGIN

		INSERT INTO AccumTemp
			(
			CustomerIntId, VehicleIntId, DriverIntId, RouteID,
			CreationCodeId, CreationDateTime,
			ClosureCodeId, ClosureDateTime, ClosureLat, ClosureLong,

			DrivingTime, DrivingDistance, DrivingFuel,
			IdleTime, IdleFuel,
			ShortIdleTime, ShortIdleFuel,
			PTONonMovingTime, PTONonMovingFuel,
			PTOMovingTime, PTOMovingDistance, PTOMovingFuel,
			CruiseControlTime, CruiseControlDistance, CruiseControlFuel,
			RSGTime, RSGDistance, RSGFuel,
			TopGearTime, TopGearDistance, TopGearFuel,
			GearDownTime, GearDownDistance, GearDownFuel,
			CoastOutOfGearTime, CoastOutOfGearDistance, CoastOutOfGearCount,
			CoastInGearTime, CoastInGearDistance, CoastInGearFuel,
			BelowSweetSpotTime, BelowSweetSpotDistance, BelowSweetSpotFuel,
			InSweetSpotTime, InSweetSpotDistance, InSweetSpotFuel,
			AboveSweetSpotTime, AboveSweetSpotDistance, AboveSweetSpotFuel,
			OverSpeedTime, OverSpeedDistance, OverSpeedFuel,
			FueledOverRPMTime, FueledOverRPMDistance, FueledOverRPMFuel,
			EngineBrakeOverRPMTime, EngineBrakeOverRPMDistance,
			AverageEngineRPM, AverageEngineRPMWhileDriving,
			DataLinkDownTime,
			ServiceBrakeTime, ServiceBrakeDistance, ServiceBrakeCount,
			EngineBrakeTime, EngineBrakeDistance, EngineBrakeCount,
			MaxRPM, MaxRPMTimestamp, MaxRPMLat, MaxRPMLong,
			MaxRoadSpeedTime, MaxRoadSpeedDistance, MaxRoadSpeedFuel, MaxRoadSpeed, MaxRoadSpeedTimestamp, MaxRoadSpeedLat, MaxRoadSpeedLong,
			LongestCoastOutofgearTime, LongestCoastOutofgearTimeDistance, LongestCoastOutofgearTimeTimestamp, LongestCoastOutofgearTimeLat, LongestCoastOutofgearTimeLong,
			LongestIdleTime, LongestIdleFuel, LongestIdleTimestamp, LongestIdleLat, LongestIdleLong,
			PanicStopCount, 
			EngineTempMidrangeTime, EngineTempHighTime, MaxEngineCoolantTemp,
			AverageEngineLoad, DataValidity,
			OverSpeedHighTime, OverSpeedHighDistance, OverSpeedHighFuel,
			TotalEngineHours, TotalVehicleDistance, TotalVehicleFuel,
			DigitalInput1Count, DigitalInput1ActivationTime,
			DigitalInput2Count, DigitalInput2ActivationTime,
			CruiseAverageEngineLoad, RSGAverageEngineLoad,
			TopGearAverageEngineLoad, GearDownAverageEngineLoad,
			AverageWeight,
			EngineLoad0Time, EngineLoad0Distance, EngineLoad0Fuel,
			EngineLoad100Time, EngineLoad100Distance, EngineLoad100Fuel,
			DriveFuelWhole, DriveFuelFrac,
			ORCount,
			CruiseTopGearTime,
			CruiseTopGearDistance,
			CruiseTopGearFuel,
			CruiseGearDownTime,
			CruiseGearDownDistance,
			CruiseGearDownFuel,
			CruiseSpeedingTime,
			CruiseSpeedingDistance,
			CruiseSpeedingFuel,
			StatusFlags,

			TopGearSpeedingTime,
			TopGearSpeedingDistance,
			TopGearSpeedingFuel,

			OverSpeedThresholdTime,
			OverSpeedThresholdDistance,
			OverSpeedThresholdFuel,

			SeqNumber
			)
		VALUES
			(
			@customerintid, @vintid, @dintid, @rid,
			@creationcid, @creationdt, 
			@closurecid, @closuredt, @closurelat, @closurelong,
	
			@d_t, @d_d, @d_f,
			@i_t, @i_f,
			@si_t, @si_f,
			@ptonm_t, @ptonm_f,
			@ptom_t, @ptom_d, @ptom_f,
			@crc_t, @crc_d, @crc_f,
			@rsg_t, @rsg_d, @rsg_f,
			@tg_t, @tg_d, @tg_f,
			@gd_t, @gd_d, @gd_f,
			@coog_t, @coog_d, @coog_c,
			@cig_t, @cig_d, @cig_f,
			@bss_t, @bss_d, @bss_f,
			@iss_t, @iss_d, @iss_f,
			@ass_t, @ass_d, @ass_f,
			@os_t, @os_d, @os_f,
			@forpm_t, @forpm_d, @forpm_f,
			@eborpm_t, @eborpm_d,
			ISNULL(@aerpm,0),  ISNULL(@aerpmwd,0),
			@dld_t,
			@sb_t, @sb_d, @sb_c,
			@eb_t, @eb_d, @eb_c,
			ISNULL(@MaxRPM,0), @MaxRPMTS, @MaxRPMLt, @MaxRPMLg,
			@MaxRoadSpeedT, @MaxRoadSpeedD, @MaxRoadSpeedF, @MaxRoadSp, @MaxRoadSpeedTS, @MaxRoadSpeedLt, @MaxRoadSpeedLg,
			@LongestCoastOutofgearT, @LongestCoastOutofgearTimeD, @LongestCoastOutofgearTimeTS, @LongestCoastOutofgearTimeLt, @LongestCoastOutofgearTimeLg,
			@LongestIdleT, @LongestIdleF, @LongestIdleTS, @LongestIdleLt, @LongestIdleLg,
			@panicstopcount,
			@EngineTempMidT, @EngineTempHighT, @MaxEngineCoolantTemp,	
			@ael, @DataVal, 
			@OverSpeedHighT, @OverSpeedHighD, @OverSpeedHighF,
			@totalenginehours, @totalvehicledist, @totalvehiclefuel,
			@di1c, @di1at,
			@di2c, @di2at,
			@cael, @rael, @tael, @gael,
			@AverageWeight,
			@EngineLoad0Time, @EngineLoad0Distance, @EngineLoad0Fuel,
			@EngineLoad100Time, @EngineLoad100Distance, @EngineLoad100Fuel,
			@DriveFuelWhole, @DriveFuelFrac,
			@ORCount,
			@CTGTime,
			@CTGDistance,
			@CTGFuel,
			@CNGDTime,
			@CNGDDistance,
			@CNGDFuel,
			@CSTime,
			@CSDistance,
			@CSFuel,
			@StatusFlags,

			@TGSTime,
			@TGSDistance,
			@TGSFuel,

			@OSTTime,
			@OSTSDistance,
			@OSTSFuel,

			@SeqNumber
			)

		-- Return AccumId
		SET @aid = SCOPE_IDENTITY()
	END
	ELSE BEGIN
		SET @aid = 0
	END

GO
