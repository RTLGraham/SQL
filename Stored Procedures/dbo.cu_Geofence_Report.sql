SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cu_Geofence_Report]
    (
      @vids NVARCHAR(MAX),
      @geofenceIds NVARCHAR(MAX),
      @uid UNIQUEIDENTIFIER,
      @sdate DATETIME,
      @edate DATETIME
    )
AS --DECLARE @vids NVARCHAR(MAX),
--		@geofenceIds NVARCHAR(MAX),
--		@sdate DATETIME,
--		@edate DATETIME,
--		@uid UNIQUEIDENTIFIER

--SET @vids = N'0EFA6728-4B2F-4637-BFD3-E9911E592856'
--SET @sdate = '2010-03-30 00:00'
--SET @edate = '2010-03-30 23:59'
--SET @uid = N'712DBE7D-3F6B-497B-8BBA-A24F66117479'
--SET @geofenceIds = N'B9C383E9-E2DF-42DB-80E3-FF1AF0E74C5F'

    DECLARE @vid UNIQUEIDENTIFIER,
			@cid UNIQUEIDENTIFIER,
			@vintid INT,
			@cintid INT,
			@geoid UNIQUEIDENTIFIER
		
    DECLARE @tbl_vehdep TABLE
        (
          VehicleId UNIQUEIDENTIFIER,
          CustomerId UNIQUEIDENTIFIER,
          VehicleIntId INT,
          CustomerIntId INT
        )

    DECLARE @tbl_events TABLE
        (
          VehicleId UNIQUEIDENTIFIER,
          Lat FLOAT,
          Lon FLOAT,
          EventDateTime DATETIME,
          WKB VARBINARY(MAX),
          CreationCodeId SMALLINT
        )

    DECLARE @tbl_wkbs TABLE
        (
          VehicleId UNIQUEIDENTIFIER,
          wkb VARBINARY(MAX),
          EventDateTime DATETIME
        )
					
    DECLARE @tbl_results TABLE
        (
          VehicleId UNIQUEIDENTIFIER,
          GeofenceId UNIQUEIDENTIFIER,
          wkb VARBINARY(MAX),
          EnterTime DATETIME,
          GeomType VARCHAR(100),
          CreationCodeId SMALLINT
        )

    DECLARE @s_date DATETIME
    DECLARE @e_date DATETIME
    DECLARE @timezone NVARCHAR(30)
    SET @timezone = [dbo].[UserPref](@uid, 600)

    SET @s_date = @sdate
    SET @e_date = @edate
    SET @sdate = [dbo].[TZ_ToUTC](@sdate, DEFAULT, @uid)
    SET @edate = [dbo].[TZ_ToUTC](@edate, DEFAULT, @uid)

    INSERT  INTO @tbl_vehdep ( VehicleId, CustomerId, VehicleIntId, CustomerIntId )
            SELECT  v.VehicleId, c.CustomerId, v.VehicleIntId, c.CustomerIntId
            FROM    dbo.[Vehicle] v
						INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
						INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
            WHERE   v.VehicleId IN ( SELECT   VALUE
                                   FROM     dbo.Split(@vids, ',') )
	
	-- Get all the event points for all the vehicles
    INSERT  INTO @tbl_events
            (
              VehicleId,
              Lat,
              Lon,
              EventDateTime,
              CreationCodeId 
            )
            SELECT DISTINCT
                    vd.VehicleId,
                    e.Lat,
                    e.Long AS Lon,
                    e.EventDateTime,
                    e.CreationCodeId
            FROM    dbo.Event e
                    INNER JOIN @tbl_vehdep vd ON e.CustomerIntId = vd.CustomerIntId
                                                 AND e.VehicleIntId = vd.VehicleIntId
            WHERE   EventDateTime BETWEEN @sdate AND @edate
                    AND e.Lat != 0
                    AND e.Long != 0
            ORDER BY e.EventDateTime

    UPDATE  @tbl_events
    SET     WKB = ST.Point(Lon, Lat, 4326)

    DECLARE evt_cur CURSOR FAST_FORWARD
        FOR SELECT  Lat,
                    Lon,
                    EventDateTime,
                    WKB,
                    evt.VehicleId,
                    CreationCodeId
            FROM    @tbl_events evt
                    INNER JOIN @tbl_vehdep v ON evt.VehicleId = v.VehicleId

    DECLARE @lat FLOAT,
        @lon FLOAT,
        @eventDate DATETIME,
        @wkb VARBINARY(MAX),
        @ccid SMALLINT,
        @lineString NVARCHAR(MAX),
        @geoName NVARCHAR(100),
        @geoFenceWkb VARBINARY(MAX)

    OPEN evt_cur
    FETCH NEXT FROM evt_cur INTO @lat, @lon, @eventDate, @wkb, @vid, @ccid
    WHILE @@FETCH_STATUS = 0
        BEGIN
			-- Within
            INSERT  INTO @tbl_results
                    (
                      VehicleId,
                      GeofenceId,
                      wkb,
                      EnterTime,
                      GeomType,
                      CreationCodeId 
                    )
                    SELECT  @vid,
                            GeofenceId,
                            the_geom,
                            @eventDate,
                            CASE WHEN ST.Within(@wkb,
                                                ST.Envelope(ST_q.the_geom)) = 1
                                 THEN 'I'
                                 WHEN ST.Within(@wkb,
                                                ST.Envelope(ST_q.the_geom)) = 0
                                 THEN 'O'
                            END,
                            @ccid
                    FROM    dbo.Geofence ST_q
                    WHERE   ST_q.GeofenceId IN (
                            SELECT  VALUE
                            FROM    dbo.Split(@geoFenceIds, ',') )
	
            FETCH NEXT FROM evt_cur INTO @lat, @lon, @eventDate, @wkb, @vid,
                @ccid
        END
    CLOSE evt_cur
    DEALLOCATE evt_cur

-- Get the 'Within' points, grouped by GeofenceId and VehicleId
    SELECT  VehicleId,
            GeofenceId,
            wkb,
            [dbo].[TZ_GetTime](EnterTime, @timezone, @uid) AS EnterTime,
            GeomType,
            CreationCodeId
    FROM    @tbl_results
    GROUP BY GeofenceId,
            VehicleId,
            GeomType,
            EnterTime,
            wkb,
            CreationCodeId
    ORDER BY EnterTime




GO
