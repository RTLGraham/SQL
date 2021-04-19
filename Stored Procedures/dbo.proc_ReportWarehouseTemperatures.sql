SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportWarehouseTemperatures]
(
	@vid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@uid UNIQUEIDENTIFIER
)
AS

	--DECLARE @vid UNIQUEIDENTIFIER,
	--		@sdate DATETIME,
	--		@edate DATETIME,
	--		@uid UNIQUEIDENTIFIER
	
	
	--SET @vid = N'9607D260-5E7F-4DFC-9D2E-3C005AB819B9'
	--SET @sdate = '2019-06-13 00:00'
	--SET @edate = '2019-06-13 23:59'
	--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'


	DECLARE @lvid UNIQUEIDENTIFIER,
			@lsdate DATETIME,
			@ledate DATETIME,
			@luid UNIQUEIDENTIFIER,
			@gid UNIQUEIDENTIFIER
		
	SET @lvid = @vid
	SET @lsdate = @sdate
	SET @ledate = @edate
	SET @luid = @uid

	DECLARE @tempmult FLOAT,
		@liquidmult FLOAT,
		@AnalogAlert1 SMALLINT,
		@AnalogAlert2 SMALLINT,
		@AnalogAlert3 SMALLINT,
		@AnalogAlert4 SMALLINT,
		@AnalogName1 nvarchar(MAX),
		@AnalogName2 nvarchar(MAX),
		@AnalogName3 nvarchar(MAX),
		@AnalogName4 nvarchar(MAX),
		@AnalogName5 nvarchar(MAX),
		@AnalogName6 nvarchar(MAX),
		@AnalogAlert1Name NVARCHAR(MAX),
		@AnalogAlert2Name NVARCHAR(MAX),
		@AnalogAlert3Name NVARCHAR(MAX),
		@AnalogAlert4Name NVARCHAR(MAX),
		@AnalogAlert1Colour NVARCHAR(MAX),
		@AnalogAlert2Colour NVARCHAR(MAX),
		@AnalogAlert3Colour NVARCHAR(MAX),
		@AnalogAlert4Colour NVARCHAR(MAX),
		@Analog1Scaling FLOAT,
		@Analog2Scaling FLOAT,
		@Analog3Scaling FLOAT,
		@Analog4Scaling FLOAT,
		@scount INT

	-- Bit used to store the status of FMTONLY
	DECLARE @fmtonlyON BIT
	SET @fmtonlyON = 0

	--This line will be executed if FMTONLY was initially set to ON
	IF (1=0) BEGIN SET @fmtonlyON = 1 END
	-- Turning off FMTONLY so the temp tables can be declared and read by the calling application
	SET FMTONLY OFF

	CREATE TABLE #period_dates (
			PeriodNum INT IDENTITY (1,1),
			StartDate DATETIME,
			EndDate DATETIME,
			PeriodType VARCHAR(MAX))
	CREATE NONCLUSTERED INDEX [IX_period_dates] ON [dbo].[#period_dates] 
	(
		[StartDate] ASC,
		[EndDate] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
      
	INSERT  INTO #period_dates ( StartDate, EndDate, PeriodType )
			SELECT  StartDate,
					EndDate,
					PeriodType
			FROM    dbo.CreateDependentDateRange(@lsdate, @ledate, @luid, NULL, NULL, 6)

	DECLARE @vehicleintid INT
	SET @vehicleintid = dbo.GetVehicleIntFromId(@lvid)

	-- Convert dates to UTC
	SET @lsdate = [dbo].TZ_ToUTC(@lsdate,default,@luid)
	SET @ledate = [dbo].TZ_ToUTC(@ledate,default,@luid)

	SELECT @scount = COUNT(*)
	FROM dbo.VehicleSensor vs
		INNER JOIN dbo.Sensor s ON vs.SensorId = s.SensorId
	WHERE vs.VehicleIntId = @vehicleintid
	OPTION (KEEPFIXED PLAN)	
		
	SET @tempmult = Cast(ISNULL(.[dbo].[UserPref](@luid, 214),1) as float)
	SET @liquidmult = Cast(ISNULL([dbo].[UserPref](@luid, 200),1) as float)

	SET @AnalogAlert1 = 1
	SET @AnalogAlert2 = 2
	SET @AnalogAlert3 = 4
	SET @AnalogAlert4 = 8

	IF @scount > 0
	BEGIN		
		SELECT	@AnalogName1 = (SELECT Description FROM dbo.VehicleSensor WHERE Enabled > 0 AND SensorId = 1 AND VehicleIntId = @vehicleintid),
				@AnalogName2 = (SELECT Description FROM dbo.VehicleSensor WHERE Enabled > 0 AND SensorId = 2 AND VehicleIntId = @vehicleintid),
				@AnalogName3 = (SELECT Description FROM dbo.VehicleSensor WHERE Enabled > 0 AND SensorId = 3 AND VehicleIntId = @vehicleintid),
				@AnalogName4 = (SELECT Description FROM dbo.VehicleSensor WHERE Enabled > 0 AND SensorId = 4 AND VehicleIntId = @vehicleintid),
				@AnalogName5 = (SELECT Description FROM dbo.VehicleSensor WHERE Enabled > 0 AND SensorId = 5 AND VehicleIntId = @vehicleintid),
				@AnalogName6 = (SELECT Description FROM dbo.VehicleSensor WHERE Enabled > 0 AND SensorId = 6 AND VehicleIntId = @vehicleintid)
          
		SET @AnalogAlert1Name = dbo.CFG_GetTemperatureAlertValueFromHistory(@lvid, 'Name_1', GETUTCDATE())
		SET @AnalogAlert2Name = dbo.CFG_GetTemperatureAlertValueFromHistory(@lvid, 'Name_2', GETUTCDATE())
		SET @AnalogAlert3Name = dbo.CFG_GetTemperatureAlertValueFromHistory(@lvid, 'Name_3', GETUTCDATE())
		SET @AnalogAlert4Name = dbo.CFG_GetTemperatureAlertValueFromHistory(@lvid, 'Name_4', GETUTCDATE())

		SET @AnalogAlert1Colour = dbo.CFG_GetTemperatureAlertValueFromHistory(@lvid, 'Colour_1', GETUTCDATE())
		SET @AnalogAlert2Colour = dbo.CFG_GetTemperatureAlertValueFromHistory(@lvid, 'Colour_2', GETUTCDATE())
		SET @AnalogAlert3Colour = dbo.CFG_GetTemperatureAlertValueFromHistory(@lvid, 'Colour_3', GETUTCDATE())
		SET @AnalogAlert4Colour = dbo.CFG_GetTemperatureAlertValueFromHistory(@lvid, 'Colour_4', GETUTCDATE())

		SELECT @Analog1Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vehicleintid AND SensorId = 1
		SELECT @Analog2Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vehicleintid AND SensorId = 2
		SELECT @Analog3Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vehicleintid AND SensorId = 3
		SELECT @Analog4Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vehicleintid AND SensorId = 4
	END	

	SELECT  p.PeriodNum,
			dbo.TZ_GetTime(p.StartDate, DEFAULT, @luid) AS DateTime,
			e.VehicleIntId,
			@lvid AS VehicleId,
			V.Registration,
	--        e.CreationCodeId,
	--        e.DigitalIO,
			e.CustomerIntId,
			CASE WHEN @scount != 0 THEN dbo.ScaleConvertAnalogValue(AVG(e.AnalogData0), @Analog1Scaling, @tempmult, @liquidmult) ELSE NULL END AS AnalogData0,
			CASE WHEN @scount != 0 THEN dbo.ScaleConvertAnalogValue(AVG(e.AnalogData1), @Analog2Scaling, @tempmult, @liquidmult) ELSE NULL END AS AnalogData1,
			CASE WHEN @scount != 0 THEN dbo.ScaleConvertAnalogValue(AVG(e.AnalogData2), @Analog3Scaling, @tempmult, @liquidmult) ELSE NULL END AS AnalogData2,
			CASE WHEN @scount != 0 THEN dbo.ScaleConvertAnalogValue(AVG(e.AnalogData3), @Analog4Scaling, @tempmult, @liquidmult) ELSE NULL END AS AnalogData3,
			NULL AS AnalogData4,
			NULL AS AnalogData5,
        
			@AnalogAlert1Name AS AnalogAlert1Name,
			@AnalogAlert2Name AS AnalogAlert2Name,
			@AnalogAlert3Name AS AnalogAlert3Name,
			@AnalogAlert4Name AS AnalogAlert4Name,
		
			@AnalogAlert1Colour AS AnalogAlert1Colour,
			@AnalogAlert2Colour AS AnalogAlert2Colour,
			@AnalogAlert3Colour AS AnalogAlert3Colour,
			@AnalogAlert4Colour AS AnalogAlert4Colour,
        
			CASE WHEN @scount != 0 THEN dbo.TestBits(AVG(e.AnalogData5), @AnalogAlert1) ELSE 0 END AS AnalogAlert1Status,
			CASE WHEN @scount != 0 THEN dbo.TestBits(AVG(e.AnalogData5), @AnalogAlert2) ELSE 0 END AS AnalogAlert2Status,
			CASE WHEN @scount != 0 THEN dbo.TestBits(AVG(e.AnalogData5), @AnalogAlert3) ELSE 0 END AS AnalogAlert3Status,
			CASE WHEN @scount != 0 THEN dbo.TestBits(AVG(e.AnalogData5), @AnalogAlert4) ELSE 0 END AS AnalogAlert4Status,
		
			COALESCE(@AnalogName1, 'N/A') AS AnalogName1,
			COALESCE(@AnalogName2, 'N/A') AS AnalogName2,
			COALESCE(@AnalogName3, 'N/A') AS AnalogName3,
			COALESCE(@AnalogName4, 'N/A') AS AnalogName4
			/*,
			CASE WHEN @scount != 0 THEN @AnalogName1 + ': ' + CONVERT(nvarchar(MAX), CONVERT(decimal(18,2), dbo.ScaleConvertAnalogValue(e.AnalogData0, @Analog1Scaling, @tempmult, @liquidmult))) ELSE NULL END AS Analog1,
			CASE WHEN @scount != 0 THEN @AnalogName2 + ': ' + CONVERT(nvarchar(MAX), CONVERT(decimal(18,2), dbo.ScaleConvertAnalogValue(e.AnalogData1, @Analog2Scaling, @tempmult, @liquidmult))) ELSE NULL END AS Analog2,
			CASE WHEN @scount != 0 THEN @AnalogName3 + ': ' + CONVERT(nvarchar(MAX), CONVERT(decimal(18,2), dbo.ScaleConvertAnalogValue(e.AnalogData2, @Analog3Scaling, @tempmult, @liquidmult))) ELSE NULL END AS Analog3,
			CASE WHEN @scount != 0 THEN @AnalogName4 + ': ' + CONVERT(nvarchar(MAX), CONVERT(decimal(18,2), dbo.ScaleConvertAnalogValue(e.AnalogData3, @Analog4Scaling, @tempmult, @liquidmult))) ELSE NULL END AS Analog4
			*/
	FROM    dbo.[Event] e
	INNER JOIN dbo.Vehicle V ON V.VehicleIntID = e.VehicleIntID
	INNER JOIN dbo.IVH i ON i.IVHId = V.IVHId
	INNER JOIN #period_dates p ON e.EventDateTime BETWEEN p.StartDate AND p.EndDate
	WHERE   e.EventDateTime BETWEEN @lsdate AND @ledate
			AND e.VehicleIntId = @vehicleintid
			AND e.CreationCodeId IS NOT NULL
			AND e.CreationCodeId NOT IN (24, 91)
			--AND (e.HardwareStatus & 192) > 0
			AND (
					i.IVHTypeId NOT IN (8,9) 
					OR 
					(i.IVHTypeId IN (8,9) AND ((e.HardwareStatus & 192) = 64 OR (e.HardwareStatus & 192) = 128))
				)
	GROUP BY p.PeriodNum, p.StartDate, e.VehicleIntId,e.CustomerIntId, V.Registration
	ORDER BY e.VehicleintId,
			p.PeriodNum ASC

	DROP TABLE #period_dates
	IF @fmtonlyON = 1 BEGIN SET FMTONLY ON END

GO
