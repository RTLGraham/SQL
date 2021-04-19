SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportAccelerometer]
    (
      @vids NVARCHAR(MAX) = NULL,
      @uid UNIQUEIDENTIFIER = NULL,
      @sdate DATETIME = NULL,
      @edate DATETIME = NULL
    )
AS 

	--DECLARE	@sdate DATETIME,
	--		@edate DATETIME,
	--		@uid UNIQUEIDENTIFIER,
	--		@vids NVARCHAR(MAX)
			
	--SET @sdate = '2019-03-01 00:00:00'
	--SET @edate = '2019-03-31 23:59:59'
	--SET @uid = N'D4F3B463-2926-4171-A162-54684C7F0600'
	--SET @vids = N'0D65A35B-FD91-47D9-A7F0-15F5FE734306'
	
    DECLARE @depid INT,
        @vid UNIQUEIDENTIFIER,
        @ivhTypeId INT,
        @s_date DATETIME,
        @e_date DATETIME,
        @timezone VARCHAR(255),
        @vehicleid UNIQUEIDENTIFIER,
        @eventtime DATETIME,
        @speedmult FLOAT,
		@distmult FLOAT

    DECLARE @static_data TABLE
        (
          VehicleId UNIQUEIDENTIFIER,
          CustomerIntId INT,
          IvhTypeId INT,
          Registration VARCHAR(255)
        )
	
    INSERT  INTO @static_data
            (
              VehicleId,
              CustomerIntId,
              IvhTypeId,
              Registration 
            )
            SELECT  v.VehicleId,
                    c.CustomerIntId,
                    i.IvhTypeId,
                    Registration
            FROM    dbo.Vehicle v
					LEFT JOIN dbo.IVH i ON v.IVHId = i.IVHId
                    INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
                    INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
            WHERE   v.VehicleId IN ( SELECT Value
                                     FROM   dbo.Split(@vids, ',') )
		
    DECLARE @results TABLE
        (
          VehicleId UNIQUEIDENTIFIER,
          Speed SMALLINT,
          Registration NVARCHAR(MAX),
          GroupName NVARCHAR(MAX),
		  VehicleTypeID INT,	
          EventTime DATETIME,
          EventTimeUtc DATETIME,
          EventId BIGINT,
          DepotId INT,
          CreationCodeId INT,
          CreationCodeName VARCHAR(50),
          Reserved INT,
          Lat FLOAT,
          Lon FLOAT,
          TotalAcceleration INT,
          TotalBraking INT,
          TotalCorner INT,
          TotalRop INT,
          TotalRop2 INT,
          TotalHarshBrake INT,
          RevGeoCode NVARCHAR(MAX),
          DriverName NVARCHAR(MAX),
		  ValidCheetahRop BIT,
		  EventDataString NVARCHAR(MAX),
		  ReverseGeocode NVARCHAR(MAX),
		  MaxForce FLOAT,
		  EndSpeed SMALLINT,
		  OdoGPS FLOAT,
		  Heading SMALLINT
        )

    SELECT  @timezone = dbo.UserPref(@uid, 600)

    SET @s_date = [dbo].TZ_ToUTC(@sdate, @timezone, @uid)
    SET @e_date = [dbo].TZ_ToUTC(@edate, @timezone, @uid)
	SET @speedmult = cast([dbo].[UserPref](@uid, 208) as float)
	SET @distmult = Cast([dbo].[UserPref](@uid, 202) as float)

	-- A, B, C, Panic Stop and ROP
    INSERT  INTO @results
            (
              VehicleId,
              Speed,
              Registration,
              --GroupName,
              VehicleTypeID,
              EventTime,
			  EventTimeUtc,
              EventId,
              DepotId,
              CreationCodeId,
              CreationCodeName,
              Reserved,
              Lat,
              Lon,
              RevGeoCode,
              DriverName,
			  ValidCheetahRop,
			  OdoGPS,
			  Heading
            )
            SELECT DISTINCT
                    sd.VehicleId,
                    Cast(Round(e.Speed * @speedmult, 0) as smallint) as Speed,
                    sd.Registration,
                    --g.GroupName,
                    v.VehicleTypeID,
                    [dbo].[TZ_GetTime](e.EventDateTime, @timezone, @uid) AS EventTime,
					e.EventDateTime,
                    e.EventId,
                    e.CustomerIntId AS DepotId,
                    e.CreationCodeId,
                    cc.[Description] AS CreationCodeDesc,
                    s.Reserved,
                    e.Lat,
                    e.Long,
                    ISNULL([dbo].[GetAddressFromLongLat](e.Lat, e.Long), '''') AS RevGeocode,
					dbo.FormatDriverNameByUser(d.DriverId, @uid) AS DriverName,
					dbo.IsValidRop(ed.EventDataString) AS ValidCheetahRop,
					Cast(Round(e.OdoGPS * @distmult, 0) as int) as OdoGPS,
					e.Heading
            FROM    dbo.Event e
					LEFT OUTER JOIN dbo.EventData ed ON e.EventId = ed.EventId
                    INNER JOIN dbo.Driver d on e.DriverIntId = d.DriverIntId
                    INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
                    --INNER JOIN GroupDetail gd ON gd.EntityDataId = v.VehicleId
                    --INNER JOIN [Group] g ON g.GroupId = gd.GroupId AND g.IsParameter = 0
                    INNER JOIN @static_data sd ON e.CustomerIntId = sd.CustomerIntId
                                                  AND v.VehicleId = sd.VehicleId
                    INNER JOIN dbo.CreationCode cc ON e.CreationCodeId = cc.CreationCodeId
                    LEFT JOIN dbo.[Snapshot] s ON e.EventId = s.EventId
                                                                AND e.CustomerIntId = s.CustomerIntId
                                                                AND s.CreationCodeId = 7
                                                                AND s.Reserved > 50
            WHERE   e.EventDateTime BETWEEN @s_date AND @e_date
					AND e.Archived = 0
                    AND v.VehicleId = sd.VehicleId
                    AND e.CreationCodeId IN (	7,  /*ROP C-F Series*/
												36, /*A*/
												37, /*B*/
												38, /*C*/
												30, /*ROP*/ 
												231, /*ROP Stage 2*/
												33  /*Harsh Brake*/)
                    AND e.Lat != 0
                    AND e.Long != 0
            GROUP BY sd.VehicleId,
					e.Speed,
                    sd.Registration,
                    --g.GroupName,
                    v.VehicleTypeID,
                    e.EventDateTime,
                    e.EventId,
                    e.CreationCodeId,
                    s.Reserved,
                    e.Lat,
                    e.Long,
                    cc.[Description],
                    e.CustomerIntId,
                    d.DriverId,
					ed.EventDataString,
					e.OdoGPS,
					e.Heading

    DELETE  FROM @results
    WHERE   CreationCodeId = 7
            AND Reserved IS NULL
			
    DELETE  FROM @results
    WHERE   CreationCodeId IN (30, 231)
			AND ValidCheetahRop = 0



    DECLARE @totalBrake INT,
        @totalAccel INT,
        @totalCorner INT,
        @totalRop INT,
        @totalRop2 INT,
        @totalHarshBrake INT,
		@evtUTC DATETIME,
		@eid BIGINT


    DECLARE veh_cur CURSOR FAST_FORWARD FORWARD_ONLY
        FOR SELECT  VehicleId, IvhTypeId
            FROM    @static_data

    OPEN veh_cur
    FETCH NEXT FROM veh_cur INTO @vid, @ivhTypeId
    WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @totalBrake = ( SELECT  COUNT(*)
                                FROM    ( SELECT DISTINCT
                                                    *
                                          FROM      @results
                                          WHERE     CreationCodeId = 36
                                                    AND VehicleId = @vid
                                        ) AS u
                              )
            SET @totalAccel = ( SELECT  COUNT(*)
                                FROM    ( SELECT DISTINCT
                                                    *
                                          FROM      @results
                                          WHERE     CreationCodeId = 37
                                                    AND VehicleId = @vid
                                        ) AS u
                              )
            SET @totalCorner = ( SELECT COUNT(*)
                                 FROM   ( SELECT DISTINCT
                                                    *
                                          FROM      @results
                                          WHERE     CreationCodeId = 38
                                                    AND VehicleId = @vid
                                        ) AS u
                               )
            SET @totalRop = ( SELECT    COUNT(*)
                              FROM      ( SELECT DISTINCT
                                                    *
                                          FROM      @results
                                          WHERE     CreationCodeId IN (7, 
																	   30)
                                                    AND VehicleId = @vid
                                        ) AS u
                            )
            SET @totalRop2 = ( SELECT    COUNT(*)
                              FROM      ( SELECT DISTINCT
                                                    *
                                          FROM      @results
                                          WHERE     CreationCodeId IN (231)
                                                    AND VehicleId = @vid
                                        ) AS u
                            )
            SET @totalHarshBrake = ( SELECT COUNT(*)
                                     FROM   ( SELECT DISTINCT
                                                        *
                                              FROM      @results
                                              WHERE     CreationCodeId = 33
                                                        AND VehicleId = @vid
                                            ) AS u
                                   )
	
            UPDATE  @results
            SET     TotalBraking = @totalBrake,
                    TotalAcceleration = @totalAccel,
                    TotalCorner = @totalCorner,
                    TotalRop = @totalRop,
                    TotalRop2 = @totalRop2,
                    TotalHarshBrake = @totalHarshBrake
            WHERE   VehicleId = @vid
	
            UPDATE  @results
            SET     CreationCodeName = 'Panic Stop'
            WHERE   CreationCodeId = 33
	
            UPDATE  @results
            SET     CreationCodeName = 'ROP'
            WHERE   CreationCodeId IN (7, 30)
            UPDATE  @results
            SET     CreationCodeName = 'ROP Stage 2'
            WHERE   CreationCodeId IN (231)
			
			
			IF @IVHTypeId IN (1,2)
			BEGIN
				UPDATE  @results
				SET     DriverName = dbo.FormatDriverNameByUser(d.DriverId, @uid)
				FROM    dbo.Driver d
				WHERE   CreationCodeId IN (7, 33) 
						AND d.DriverId = dbo.GetDriverIdFromEvent_CFSeries(VehicleId, dbo.TZ_ToUtc(EventTime, DEFAULT, @uid))
						AND VehicleId = @vid
			END
			
            FETCH NEXT FROM veh_cur INTO @vid, @ivhTypeId
        END
    CLOSE veh_cur
    DEALLOCATE veh_cur

	DECLARE @ed NVARCHAR(MAX), @absX FLOAT, @absY FLOAT, @endSpeed SMALLINT

    DECLARE res_cur CURSOR FAST_FORWARD FORWARD_ONLY
        FOR SELECT  VehicleId, EventId, EventTimeUtc
            FROM    @results
			WHERE	CreationCodeId IN (36,37,38)
			
    OPEN res_cur
    FETCH NEXT FROM res_cur INTO @vid, @eid, @evtUTC
    WHILE @@FETCH_STATUS = 0
        BEGIN
			SELECT @ed = NULL, @absX = NULL, @absY = NULL, @endSpeed = NULL

			SELECT @ed = evtData.EventDataString
			FROM @results r
				LEFT OUTER JOIN 
					(
						SELECT TOP 1
							   ed.EventDataString ,
                               vEd.VehicleId ,
							   @eid AS StartEventId,
							   ede.Speed
						FROM dbo.EventData ed
							INNER JOIN dbo.Event ede ON ede.EventId = ed.EventId
							INNER JOIN dbo.Vehicle vEd ON vEd.VehicleIntId = ed.VehicleIntId
						WHERE vEd.VehicleId = @vid 
							AND ed.EventId > @eid 
							AND ed.EventDateTime BETWEEN @evtUTC AND DATEADD(MINUTE, 1, @evtUTC) 
							AND ed.EventDataName LIKE '%HMV%'
					) evtData ON  evtData.VehicleId = r.VehicleId
			WHERE r.EventId = @eid

			IF @ed IS NOT NULL
			BEGIN
				SELECT @absX = ABS(CAST(Value AS FLOAT)) FROM dbo.Split(@ed, ';') WHERE Id = 4
				SELECT @absY = ABS(CAST(Value AS FLOAT)) FROM dbo.Split(@ed, ';') WHERE Id = 5
				SELECT @endSpeed = CAST(Value AS SMALLINT) FROM dbo.Split(@ed, ';') WHERE Id = 12
			END

			UPDATE @results 
			SET EventDataString = @ed,
				MaxForce = CASE WHEN @absX > @absY THEN @absX ELSE @absY END  / 1000.0,
				EndSpeed = ROUND(@endSpeed * @speedmult, 0)
			WHERE EventId = @eid

            FETCH NEXT FROM res_cur INTO @vid, @eid, @evtUTC
        END
    CLOSE res_cur
    DEALLOCATE res_cur


    SELECT DISTINCT
            VehicleId,
            Speed,
            Registration,
            --GroupName,
            VehicleTypeID,
            EventTime,
            EventId,
            DepotId,
            CASE WHEN CreationCodeId = 30
				 THEN 7
				 ELSE CreationCodeId
			END AS CreationCodeId,
            CreationCodeName,
            Lat,
            Lon,
            TotalAcceleration,
            TotalBraking,
            TotalCorner,
            TotalRop,
            TotalRop2,
            TotalHarshBrake,  
            DriverName,
			CAST(Lat AS NVARCHAR(MAX)) + ', ' + CAST(Lon AS NVARCHAR(MAX)) AS LatLonString,
			[dbo].[GetAddressFromLongLat] (Lat, Lon) as ReverseGeoCode,
			MaxForce,
			EndSpeed,
			OdoGPS,
			Heading
    FROM    @results

GO
