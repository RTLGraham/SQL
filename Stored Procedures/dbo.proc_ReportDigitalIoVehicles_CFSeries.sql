SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Dmitrijs Jurins>
-- Create date: <2011-05-06>
-- Description:	<D_ and Dev_ DB unique procedure. Handles Digital inputs from Hoyer C&F Series trackers>
-- =============================================
CREATE PROCEDURE [dbo].[proc_ReportDigitalIoVehicles_CFSeries]
	@vids NVARCHAR(MAX) = NULL, 
    @uid UNIQUEIDENTIFIER = NULL,
	@sdate DATETIME = NULL, 
	@edate DATETIME = NULL,
    @dios NVARCHAR(MAX) = NULL
AS
BEGIN

	SET NOCOUNT ON;
				
	--DECLARE	@sdate DATETIME,
	--		@edate DATETIME,
	--		@uid UNIQUEIDENTIFIER,
	--		@vids NVARCHAR(MAX),
	--		@dios NVARCHAR(MAX)
			
	--SET @vids = N'183DF7B6-BE32-E011-A26E-001C23C37503'--N'B5F9FEB0-BE32-E011-A26E-001C23C37503,183DF7B6-BE32-E011-A26E-001C23C37503,D36A6893-BE32-E011-A26E-001C23C37503'
	--SET @uid = N'9DB9BB41-CE6F-45BA-B13B-3F72A0A28D23'
	--SET @sdate = '2011-08-01 00:00'
	--SET @edate = '2011-08-01 23:59'
	--SET @dios = '322'
	
	
	DECLARE @results TABLE
	(
		VehicleId UNIQUEIDENTIFIER,
		Registration NVARCHAR(MAX),
		DigitalIoTypeId INT,
		DigitalIoTypeName NVARCHAR(MAX),
		EventTime DATETIME,
		EventId BIGINT,
		CustomerId UNIQUEIDENTIFIER,
		DigitalIo INT,
		CreationCodeId INT,
		Lat FLOAT,
		Lon FLOAT,
		OnOff BIT,
		TotalOn INT,
		TotalOff INT,
		StatusString VARCHAR(255),
		DigitalIoUri NVARCHAR(512),
		Duration INT
	)
	DECLARE @cursTable TABLE
	(
		VehicleId UNIQUEIDENTIFIER,
		Registration NVARCHAR(MAX),
		DigitalIoTypeId INT,
		DigitalIoTypeName NVARCHAR(MAX),
		EventTime DATETIME,
		EventId BIGINT,
		CustomerId UNIQUEIDENTIFIER,
		DigitalIo INT,
		CreationCodeId INT,
		Lat FLOAT,
		Lon FLOAT,
		OnOff BIT,
		TotalOn INT,
		TotalOff INT,
		StatusString VARCHAR(255),
		DigitalIoUri NVARCHAR(512),
		HeadwayWarning2 INT,
		CollisionWarning INT,
		UrbanCollisionWarning INT,
		HeadwayWarning INT,
		LaneDeparture INT
	)
	DECLARE @startFlag INT,
			@vid UNIQUEIDENTIFIER,
			@prevInput INT,
			@input INT,
			@VehicleId UNIQUEIDENTIFIER, 
			@Registration NVARCHAR(MAX), 
			@EventTime DATETIME, 
			@EventId BIGINT, 
			@CustomerId UNIQUEIDENTIFIER, 
			@Lat FLOAT, 
			@Lon FLOAT,
			@count INT,
			@timezone VARCHAR(255),
			@utc_sdate DATETIME,
			@utc_edate DATETIME
	
	SELECT @timezone = dbo.UserPref(@uid, 600)

	SET @utc_sdate = [dbo].TZ_ToUTC(@sdate,@timezone,@uid)
	SET @utc_edate = [dbo].TZ_ToUTC(@edate,@timezone,@uid)
	
	INSERT INTO @cursTable
			(	VehicleId , Registration , DigitalIoTypeId, DigitalIoTypeName ,EventTime , 
				EventId ,CustomerId ,DigitalIo ,CreationCodeId ,
				Lat ,Lon ,OnOff ,TotalOn ,
				TotalOff ,StatusString ,DigitalIoUri ,
				HeadwayWarning2 ,
				CollisionWarning ,
				UrbanCollisionWarning ,
				HeadwayWarning ,
				LaneDeparture
			)
	SELECT v.VehicleId, v.Registration, NULL, NULL, e.EventDateTime, 
		e.EventId, dv.CustomerId, NULL, NULL, 
		e.Lat, e.Long, NULL, NULL, 
		NULL, NULL, NULL,
		CASE WHEN (DigitalIO & 0x02) / 0x02 = 0 THEN 0 ELSE 1 END  AS HeadwayWarning2,
		CASE WHEN (DigitalIO & 0x04) / 0x04 = 0 THEN 1 ELSE 0 END  AS CollisionWarning,
		CASE WHEN (DigitalIO & 0x08) / 0x08 = 0 THEN 1 ELSE 0 END  AS UrbanCollisionWarning,
		CASE WHEN (DigitalIO & 0x10) / 0x10 = 0 THEN 1 ELSE 0 END  AS HeadwayWarning,
		CASE WHEN (DigitalIO & 0x20) / 0x20 = 0 THEN 1 ELSE 0 END  AS LaneDeparture
	FROM dbo.Event e 
		INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.CustomerVehicle dv ON v.VehicleId = dv.VehicleId AND dv.Archived = 0
	WHERE v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
		AND e.CreationCodeId  = 6
		AND e.EventDateTime BETWEEN @utc_sdate AND @utc_edate
	ORDER BY EventDateTime



	DECLARE vehicles_cur CURSOR FAST_FORWARD FOR SELECT Value FROM dbo.Split(@vids, ',')
	OPEN vehicles_cur FETCH NEXT FROM vehicles_cur INTO @vid WHILE @@fetch_status = 0
	BEGIN
		/*******************************************************************************
		*
		*								Headway Warning 2
		*
		********************************************************************************/
		SET @count = NULL
		SELECT TOP 1 @count = VALUE FROM dbo.Split(@dios, ',') WHERE Value = 5--320
		IF @count IS NOT NULL
		BEGIN
			DECLARE headwayWarning2_cur CURSOR FAST_FORWARD FOR 
			SELECT VehicleId, Registration, EventTime, EventId, CustomerId, Lat, Lon, HeadwayWarning2 FROM @cursTable WHERE VehicleId = @vid ORDER BY EventTime ASC
			SET @startFlag = 0
			SET @input = 0
			SET @prevInput = 0
			OPEN headwayWarning2_cur
				FETCH NEXT FROM headwayWarning2_cur INTO @VehicleId, @Registration, @EventTime, @EventId, @CustomerId, @Lat, @Lon, @input WHILE @@fetch_status = 0
				BEGIN
					IF @startFlag = 0
					BEGIN
						IF @input = 1
						BEGIN
							SET @startFlag = 1
							INSERT INTO @results ( VehicleId ,Registration ,DigitalIoTypeId ,DigitalIoTypeName ,EventTime ,EventId ,CustomerId ,DigitalIo ,CreationCodeId ,Lat ,Lon ,OnOff ,TotalOn ,TotalOff ,StatusString ,DigitalIoUri)
							VALUES  ( @VehicleId , -- VehicleId - uniqueidentifier
									  @Registration , -- Registration - nvarchar(max)
									  5,
									  'Headway 2' , -- DigitalIoTypeName - nvarchar(max)
									  [dbo].[TZ_GetTime]( @EventTime, @timezone, @uid), -- EventTime - datetime
									  @EventId , -- EventId - bigint
									  @CustomerId , -- CustomerId - int
									  320 , -- DigitalIo - int
									  6 , -- CreationCodeId - int
									  @Lat , -- Lat - float
									  @Lon , -- Lon - float
									  @input , -- OnOff - bit
									  0 , -- TotalOn - int
									  0 , -- TotalOff - int
									  'On' , -- StatusString - varchar(255)
									  '/RTLTwo;component/Resources/Images/DigitalIO/Events/HeadwayWarning2.png'  -- DigitalIoUri - nvarchar(512)
									)	
						END
					END
					ELSE
					BEGIN
						IF @input != @prevInput
						BEGIN
							INSERT INTO @results ( VehicleId ,Registration ,DigitalIoTypeId ,DigitalIoTypeName ,EventTime ,EventId ,CustomerId ,DigitalIo ,CreationCodeId ,Lat ,Lon ,OnOff ,TotalOn ,TotalOff ,StatusString ,DigitalIoUri)
							VALUES  ( @VehicleId , -- VehicleId - uniqueidentifier
									  @Registration , -- Registration - nvarchar(max)
									  5,
									  'Headway 2' , -- DigitalIoTypeName - nvarchar(max)
									  [dbo].[TZ_GetTime]( @EventTime, @timezone, @uid) , -- EventTime - datetime
									  @EventId , -- EventId - bigint
									  @CustomerId , -- CustomerId - int
									  320 , -- DigitalIo - int
									  CASE WHEN @input = 1 THEN 6 ELSE 7 END, -- CreationCodeId - int
									  @Lat , -- Lat - float
									  @Lon , -- Lon - float
									  @input , -- OnOff - bit
									  0 , -- TotalOn - int
									  0 , -- TotalOff - int
									  CASE WHEN @input = 1 THEN 'On' ELSE 'Off' END, -- StatusString - varchar(255)
									  '/RTLTwo;component/Resources/Images/DigitalIO/Events/HeadwayWarning2.png'  -- DigitalIoUri - nvarchar(512)
									)
						END
					END
					
					SET @prevInput = @input
					FETCH NEXT FROM headwayWarning2_cur INTO @VehicleId, @Registration, @EventTime, @EventId, @CustomerId, @Lat, @Lon, @input
				END
			CLOSE headwayWarning2_cur
			DEALLOCATE headwayWarning2_cur	
		END
		
		/*******************************************************************************
		*
		*							Collision Warning
		*
		********************************************************************************/
		SET @count = NULL
		SELECT TOP 1 @count = VALUE FROM dbo.Split(@dios, ',') WHERE Value = 1--321
		IF @count IS NOT NULL
		BEGIN
			DECLARE collisionWarning_cur CURSOR FAST_FORWARD FOR 
			SELECT VehicleId, Registration, EventTime, EventId, CustomerId, Lat, Lon, CollisionWarning FROM @cursTable WHERE VehicleId = @vid ORDER BY EventTime ASC
			SET @startFlag = 0
			SET @input = 0
			SET @prevInput = 0
			OPEN collisionWarning_cur
				FETCH NEXT FROM collisionWarning_cur INTO @VehicleId, @Registration, @EventTime, @EventId, @CustomerId, @Lat, @Lon, @input WHILE @@fetch_status = 0
				BEGIN
					IF @startFlag = 0
					BEGIN
						IF @input = 1
						BEGIN
							SET @startFlag = 1
							INSERT INTO @results ( VehicleId ,Registration ,DigitalIoTypeId ,DigitalIoTypeName ,EventTime ,EventId ,CustomerId ,DigitalIo ,CreationCodeId ,Lat ,Lon ,OnOff ,TotalOn ,TotalOff ,StatusString ,DigitalIoUri)
							VALUES  ( @VehicleId , -- VehicleId - uniqueidentifier
									  @Registration , -- Registration - nvarchar(max)
									  1,
									  'Collision' , -- DigitalIoTypeName - nvarchar(max)
									  [dbo].[TZ_GetTime]( @EventTime, @timezone, @uid) , -- EventTime - datetime
									  @EventId , -- EventId - bigint
									  @CustomerId , -- CustomerId - int
									  321, -- DigitalIo - int
									  8, -- CreationCodeId - int
									  @Lat , -- Lat - float
									  @Lon , -- Lon - float
									  @input , -- OnOff - bit
									  0 , -- TotalOn - int
									  0 , -- TotalOff - int
									  'On' , -- StatusString - varchar(255)
									  '/RTLTwo;component/Resources/Images/DigitalIO/Events/CollisionWarning.png'  -- DigitalIoUri - nvarchar(512)
									)	
						END
					END
					ELSE
					BEGIN
						IF @input != @prevInput
						BEGIN
							INSERT INTO @results ( VehicleId ,Registration ,DigitalIoTypeId ,DigitalIoTypeName ,EventTime ,EventId ,CustomerId ,DigitalIo ,CreationCodeId ,Lat ,Lon ,OnOff ,TotalOn ,TotalOff ,StatusString ,DigitalIoUri)
							VALUES  ( @VehicleId , -- VehicleId - uniqueidentifier
									  @Registration , -- Registration - nvarchar(max)
									  1,
									  'Collision' , -- DigitalIoTypeName - nvarchar(max)
									  [dbo].[TZ_GetTime]( @EventTime, @timezone, @uid) , -- EventTime - datetime
									  @EventId , -- EventId - bigint
									  @CustomerId , -- CustomerId - int
									  321 , -- DigitalIo - int
									  CASE WHEN @input = 1 THEN 8 ELSE 9 END, -- CreationCodeId - int
									  @Lat , -- Lat - float
									  @Lon , -- Lon - float
									  @input , -- OnOff - bit
									  0 , -- TotalOn - int
									  0 , -- TotalOff - int
									  CASE WHEN @input = 1 THEN 'On' ELSE 'Off' END, -- StatusString - varchar(255)
									  '/RTLTwo;component/Resources/Images/DigitalIO/Events/CollisionWarning.png'  -- DigitalIoUri - nvarchar(512)
									)
						END
					END
					
					SET @prevInput = @input
					FETCH NEXT FROM collisionWarning_cur INTO @VehicleId, @Registration, @EventTime, @EventId, @CustomerId, @Lat, @Lon, @input
				END
			CLOSE collisionWarning_cur
			DEALLOCATE collisionWarning_cur
		END
		/*******************************************************************************
		*
		*							Urban Collision Warning
		*
		********************************************************************************/
		SET @count = NULL
		SELECT TOP 1 @count = VALUE FROM dbo.Split(@dios, ',') WHERE Value = 11--322
		IF @count IS NOT NULL
		BEGIN
			DECLARE urbanCollisionWarning_cur CURSOR FAST_FORWARD FOR 
			SELECT VehicleId, Registration, EventTime, EventId, CustomerId, Lat, Lon, UrbanCollisionWarning FROM @cursTable WHERE VehicleId = @vid ORDER BY EventTime ASC
			SET @startFlag = 0
			SET @input = 0
			SET @prevInput = 0
			OPEN urbanCollisionWarning_cur
				FETCH NEXT FROM urbanCollisionWarning_cur INTO @VehicleId, @Registration, @EventTime, @EventId, @CustomerId, @Lat, @Lon, @input WHILE @@fetch_status = 0
				BEGIN
					IF @startFlag = 0
					BEGIN
						IF @input = 1
						BEGIN
							SET @startFlag = 1
							INSERT INTO @results ( VehicleId ,Registration ,DigitalIoTypeId ,DigitalIoTypeName ,EventTime ,EventId ,CustomerId ,DigitalIo ,CreationCodeId ,Lat ,Lon ,OnOff ,TotalOn ,TotalOff ,StatusString ,DigitalIoUri)
							VALUES  ( @VehicleId , -- VehicleId - uniqueidentifier
									  @Registration , -- Registration - nvarchar(max)
									  11,
									  'Urban Collision' , -- DigitalIoTypeName - nvarchar(max)
									  [dbo].[TZ_GetTime]( @EventTime, @timezone, @uid) , -- EventTime - datetime
									  @EventId , -- EventId - bigint
									  @CustomerId , -- CustomerId - int
									  322 , -- DigitalIo - int
									  10, -- CreationCodeId - int
									  @Lat , -- Lat - float
									  @Lon , -- Lon - float
									  @input , -- OnOff - bit
									  0 , -- TotalOn - int
									  0 , -- TotalOff - int
									  'On' , -- StatusString - varchar(255)
									  '/RTLTwo;component/Resources/Images/DigitalIO/Events/UrbanCollisionWarning.png'  -- DigitalIoUri - nvarchar(512)
									)	
						END
					END
					ELSE
					BEGIN
						IF @input != @prevInput
						BEGIN
							INSERT INTO @results ( VehicleId ,Registration ,DigitalIoTypeId ,DigitalIoTypeName ,EventTime ,EventId ,CustomerId ,DigitalIo ,CreationCodeId ,Lat ,Lon ,OnOff ,TotalOn ,TotalOff ,StatusString ,DigitalIoUri)
							VALUES  ( @VehicleId , -- VehicleId - uniqueidentifier
									  @Registration , -- Registration - nvarchar(max)
									  11,
									  'Urban Collision' , -- DigitalIoTypeName - nvarchar(max)
									  [dbo].[TZ_GetTime]( @EventTime, @timezone, @uid) , -- EventTime - datetime
									  @EventId , -- EventId - bigint
									  @CustomerId , -- CustomerId - int
									  322 , -- DigitalIo - int
									  CASE WHEN @input = 1 THEN 10 ELSE 11 END, -- CreationCodeId - int
									  @Lat , -- Lat - float
									  @Lon , -- Lon - float
									  @input , -- OnOff - bit
									  0 , -- TotalOn - int
									  0 , -- TotalOff - int
									  CASE WHEN @input = 1 THEN 'On' ELSE 'Off' END, -- StatusString - varchar(255)
									  '/RTLTwo;component/Resources/Images/DigitalIO/Events/UrbanCollisionWarning.png'  -- DigitalIoUri - nvarchar(512)
									)
						END
					END
					
					SET @prevInput = @input
					FETCH NEXT FROM urbanCollisionWarning_cur INTO @VehicleId, @Registration, @EventTime, @EventId, @CustomerId, @Lat, @Lon, @input
				END
			CLOSE urbanCollisionWarning_cur
			DEALLOCATE urbanCollisionWarning_cur
		END
		/*******************************************************************************
		*
		*								Headway Warning
		*
		********************************************************************************/
		SET @count = NULL
		SELECT TOP 1 @count = VALUE FROM dbo.Split(@dios, ',') WHERE Value = 4--323
		IF @count IS NOT NULL
		BEGIN
			DECLARE headwayWarning_cur CURSOR FAST_FORWARD FOR 
			SELECT VehicleId, Registration, EventTime, EventId, CustomerId, Lat, Lon, HeadwayWarning FROM @cursTable WHERE VehicleId = @vid ORDER BY EventTime ASC
			SET @startFlag = 0
			SET @input = 0
			SET @prevInput = 0
			OPEN headwayWarning_cur
				FETCH NEXT FROM headwayWarning_cur INTO @VehicleId, @Registration, @EventTime, @EventId, @CustomerId, @Lat, @Lon, @input WHILE @@fetch_status = 0
				BEGIN
					IF @startFlag = 0
					BEGIN
						IF @input = 1
						BEGIN
							SET @startFlag = 1
							INSERT INTO @results ( VehicleId ,Registration ,DigitalIoTypeId ,DigitalIoTypeName ,EventTime ,EventId ,CustomerId ,DigitalIo ,CreationCodeId ,Lat ,Lon ,OnOff ,TotalOn ,TotalOff ,StatusString ,DigitalIoUri)
							VALUES  ( @VehicleId , -- VehicleId - uniqueidentifier
									  @Registration , -- Registration - nvarchar(max)
									  4,
									  'Headway' , -- DigitalIoTypeName - nvarchar(max)
									  [dbo].[TZ_GetTime]( @EventTime, @timezone, @uid) , -- EventTime - datetime
									  @EventId , -- EventId - bigint
									  @CustomerId , -- CustomerId - int
									  323 , -- DigitalIo - int
									  12 , -- CreationCodeId - int
									  @Lat , -- Lat - float
									  @Lon , -- Lon - float
									  @input , -- OnOff - bit
									  0 , -- TotalOn - int
									  0 , -- TotalOff - int
									  'On' , -- StatusString - varchar(255)
									  '/RTLTwo;component/Resources/Images/DigitalIO/Events/HeadwayWarning.png'  -- DigitalIoUri - nvarchar(512)
									)	
						END
					END
					ELSE
					BEGIN
						IF @input != @prevInput
						BEGIN
							INSERT INTO @results ( VehicleId ,Registration ,DigitalIoTypeId ,DigitalIoTypeName ,EventTime ,EventId ,CustomerId ,DigitalIo ,CreationCodeId ,Lat ,Lon ,OnOff ,TotalOn ,TotalOff ,StatusString ,DigitalIoUri)
							VALUES  ( @VehicleId , -- VehicleId - uniqueidentifier
									  @Registration , -- Registration - nvarchar(max)
									  4,
									  'Headway' , -- DigitalIoTypeName - nvarchar(max)
									  [dbo].[TZ_GetTime]( @EventTime, @timezone, @uid) , -- EventTime - datetime
									  @EventId , -- EventId - bigint
									  @CustomerId , -- CustomerId - int
									  323 , -- DigitalIo - int
									  CASE WHEN @input = 1 THEN 12 ELSE 13 END, -- CreationCodeId - int
									  @Lat , -- Lat - float
									  @Lon , -- Lon - float
									  @input , -- OnOff - bit
									  0 , -- TotalOn - int
									  0 , -- TotalOff - int
									  CASE WHEN @input = 1 THEN 'On' ELSE 'Off' END, -- StatusString - varchar(255)
									  '/RTLTwo;component/Resources/Images/DigitalIO/Events/HeadwayWarning.png'  -- DigitalIoUri - nvarchar(512)
									)
						END
					END
					
					SET @prevInput = @input
					FETCH NEXT FROM headwayWarning_cur INTO @VehicleId, @Registration, @EventTime, @EventId, @CustomerId, @Lat, @Lon, @input
				END
			CLOSE headwayWarning_cur
			DEALLOCATE headwayWarning_cur
		END
		/*******************************************************************************
		*
		*								Lane Departure
		*
		********************************************************************************/
		SET @count = NULL
		SELECT TOP 1 @count = VALUE FROM dbo.Split(@dios, ',') WHERE Value = 7--324
		IF @count IS NOT NULL
		BEGIN
			DECLARE laneDeparture_cur CURSOR FAST_FORWARD FOR 
			SELECT VehicleId, Registration, EventTime, EventId, CustomerId, Lat, Lon, LaneDeparture FROM @cursTable WHERE VehicleId = @vid ORDER BY EventTime ASC
			SET @startFlag = 0
			SET @input = 0
			SET @prevInput = 0
			OPEN laneDeparture_cur
				FETCH NEXT FROM laneDeparture_cur INTO @VehicleId, @Registration, @EventTime, @EventId, @CustomerId, @Lat, @Lon, @input WHILE @@fetch_status = 0
				BEGIN
					IF @startFlag = 0
					BEGIN
						IF @input = 1
						BEGIN
							SET @startFlag = 1
							INSERT INTO @results ( VehicleId ,Registration ,DigitalIoTypeId ,DigitalIoTypeName ,EventTime ,EventId ,CustomerId ,DigitalIo ,CreationCodeId ,Lat ,Lon ,OnOff ,TotalOn ,TotalOff ,StatusString ,DigitalIoUri)
							VALUES  ( @VehicleId , -- VehicleId - uniqueidentifier
									  @Registration , -- Registration - nvarchar(max)
									  7,
									  'Lane Departure' , -- DigitalIoTypeName - nvarchar(max)
									  [dbo].[TZ_GetTime]( @EventTime, @timezone, @uid) , -- EventTime - datetime
									  @EventId , -- EventId - bigint
									  @CustomerId , -- CustomerId - int
									  324 , -- DigitalIo - int
									  14 , -- CreationCodeId - int
									  @Lat , -- Lat - float
									  @Lon , -- Lon - float
									  @input , -- OnOff - bit
									  0 , -- TotalOn - int
									  0 , -- TotalOff - int
									  'On' , -- StatusString - varchar(255)
									  '/RTLTwo;component/Resources/Images/DigitalIO/Events/LaneDeparture.png'  -- DigitalIoUri - nvarchar(512)
									)	
						END
					END
					ELSE
					BEGIN
						IF @input != @prevInput
						BEGIN
							INSERT INTO @results ( VehicleId ,Registration ,DigitalIoTypeId ,DigitalIoTypeName ,EventTime ,EventId ,CustomerId ,DigitalIo ,CreationCodeId ,Lat ,Lon ,OnOff ,TotalOn ,TotalOff ,StatusString ,DigitalIoUri)
							VALUES  ( @VehicleId , -- VehicleId - uniqueidentifier
									  @Registration , -- Registration - nvarchar(max)
									  7,
									  'Lane Departure' , -- DigitalIoTypeName - nvarchar(max)
									  [dbo].[TZ_GetTime]( @EventTime, @timezone, @uid) , -- EventTime - datetime
									  @EventId , -- EventId - bigint
									  @CustomerId , -- CustomerId - int
									  324 , -- DigitalIo - int
									  CASE WHEN @input = 1 THEN 14 ELSE 15 END, -- CreationCodeId - int
									  @Lat , -- Lat - float
									  @Lon , -- Lon - float
									  @input , -- OnOff - bit
									  0 , -- TotalOn - int
									  0 , -- TotalOff - int
									  CASE WHEN @input = 1 THEN 'On' ELSE 'Off' END, -- StatusString - varchar(255)
									  '/RTLTwo;component/Resources/Images/DigitalIO/Events/LaneDeparture.png'  -- DigitalIoUri - nvarchar(512)
									)
						END
					END
					
					SET @prevInput = @input
					FETCH NEXT FROM laneDeparture_cur INTO @VehicleId, @Registration, @EventTime, @EventId, @CustomerId, @Lat, @Lon, @input
				END
			CLOSE laneDeparture_cur
			DEALLOCATE laneDeparture_cur
		END
		FETCH NEXT FROM vehicles_cur INTO @vid
	END
	CLOSE vehicles_cur
	DEALLOCATE vehicles_cur

	UPDATE @results
	SET TotalOn = timesRes.OnTime, TotalOff = timesRes.OffTime
	FROM
	(
		SELECT r.DigitalIo AS dio, SUM(r.Duration) AS OnTime, DATEDIFF(ss, @sdate, @edate) - SUM(r.Duration) AS OffTime
		FROM
		(
			SELECT r1.DigitalIo, DATEDIFF(ss, r1.EventTime, MIN(r2.EventTime)) AS Duration
			FROM @results r1
				LEFT OUTER JOIN @results r2 ON 
					r1.DigitalIo = r2.DigitalIo AND 
					r2.EventTime > r1.EventTime AND 
					r2.CreationCodeId = r1.CreationCodeId + 1
			GROUP BY r1.DigitalIo, r1.EventTime
		) r
		GROUP BY DigitalIo
	) timesRes
	WHERE DigitalIo = timesRes.dio		
	
	SELECT DISTINCT VehicleId, Registration, DigitalIoTypeId, DigitalIoTypeName , EventTime , EventId , CustomerId , DigitalIo , CreationCodeId , Lat , Lon , OnOff , TotalOn , TotalOff, StatusString, DigitalIoUri 
	FROM @results  WHERE Lat != 0 AND Lon != 0
END

GO
