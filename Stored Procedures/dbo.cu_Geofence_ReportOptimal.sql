SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cu_Geofence_ReportOptimal]
(
		@vids NVARCHAR(MAX),
		@geofenceIds NVARCHAR(MAX),
		@uid UNIQUEIDENTIFIER,
		@sdate DATETIME,
		@edate DATETIME
)
AS
	SET NOCOUNT ON
	
	--/*Rewrite this report without using ST. (use SQL spatial instead)*/
	--SELECT 1
	--/*
	
	--DECLARE	@vids NVARCHAR(MAX),
	--		@geofenceIds NVARCHAR(MAX),
	--		@uid UNIQUEIDENTIFIER,
	--		@sdate DATETIME,
	--		@edate DATETIME
	--	SET @vids = N'6CD1331B-F7FC-4866-A333-8FEE45667F33'
	--	SET @sdate = '2016-12-01 00:00:00'
	--	SET @edate = '2016-12-01 23:59:00'
	--	SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
	--	SET @geofenceids = N'EC5CEEAC-9E02-4951-B87C-1DC95CF6F642'


		--IF OBJECT_ID('tempdb..#data') IS NOT NULL
		--BEGIN
		--	DROP TABLE #data
		--END
		--IF OBJECT_ID('tempdb..#tbl_results') IS NOT NULL
		--BEGIN
		--	DROP TABLE #tbl_results
		--END
		--IF OBJECT_ID('tempdb..#vehtab') IS NOT NULL
		--BEGIN
		--	DROP TABLE #vehtab
		--END
		--IF OBJECT_ID('tempdb..#geotab') IS NOT NULL
		--BEGIN
		--	DROP TABLE #geotab
		--END

		-- Bit used to store the status of FMTONLY
		DECLARE @fmtonlyON BIT
		SET @fmtonlyON = 0

		--This line will be executed if FMTONLY was initially set to ON
		IF (1=0) BEGIN SET @fmtonlyON = 1 END
		-- Turning off FMTONLY so the temp tables can be declared and read by the calling application
		SET FMTONLY OFF

		DECLARE @lvids NVARCHAR(MAX),
				@lgeofenceids NVARCHAR(MAX),
				@lsdate DATETIME,
				@ledate DATETIME,
				@luid UNIQUEIDENTIFIER
		SET @lvids = @vids
		SET @lgeofenceids = @geofenceIds
		SET @lsdate = @sdate
		SET @ledate = @edate
		SET @luid = @uid

		/*Declare variables*/
		DECLARE @s_date DATETIME,
				@e_date DATETIME,
				@timezone NVARCHAR(30),
				@geoid UNIQUEIDENTIFIER,
				@wkb VARBINARY(MAX),
				@vid UNIQUEIDENTIFIER,
				@vintid INT,
				@lineString VARBINARY(MAX),
				@lat FLOAT,
				@lon FLOAT,
				@in BIT,
				@covers BIT,
				@periodLength INT,
				@lsdate_period DATETIME,
				@ledate_period DATETIME,
				@linestring_wkt NVARCHAR(MAX),
				@mindatetime DATETIME,
				@maxdatetime DATETIME,
				@build BIT
				
		CREATE TABLE #data
		(
			VehicleId UNIQUEIDENTIFIER,
			VehicleIntId INT,
			EventDateTime DATETIME,
			CreationCodeId SMALLINT,
			Lat FLOAT,
			Long FLOAT
		)
		CREATE NONCLUSTERED INDEX [#data_vehicleintid_eventdatetime] ON #data
		(
			[VehicleIntId] ASC,
			[EventDateTime] ASC
		)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

		------CREATE TABLE #geotab
		------(
		------	GeofenceId UNIQUEIDENTIFIER, 
		------	WKB VARBINARY(MAX),
		------	CentreLat FLOAT,
		------	CentreLon FLOAT
		------)
		------CREATE NONCLUSTERED INDEX [#geotab_geofence] ON #geotab
		------(
		------	[GeofenceId] ASC
		------)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

		CREATE TABLE #vehtab 
		(
			VehicleId UNIQUEIDENTIFIER, 
			VehicleIntId INT,
			LineString GEOMETRY,
			StartDate DATETIME,
			EndDate DATETIME
		)
		CREATE NONCLUSTERED INDEX [#vehtab_vintdate] ON #vehtab
		(
			[VehicleIntId] ASC,
			[StartDate] ASC,
			[EndDate] ASC
		)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

		DECLARE @vintids TABLE
		(
			VehicleId UNIQUEIDENTIFIER,
			VehicleIntId INT
		)
		CREATE TABLE #tbl_results
		(
			VehicleId UNIQUEIDENTIFIER,
			VehicleIntId INT,
			GeofenceId UNIQUEIDENTIFIER,
			wkb varbinary(MAX),
			EnterTime DATETIME,
			GeomType VARCHAR(100),
			CreationCodeId SMALLINT,
			EventDateTime DATETIME
		)
		
		CREATE NONCLUSTERED INDEX [#tbl_results_ggve] ON #tbl_results
		(
			[GeofenceId] ASC,
			[GeomType] ASC,
			[VehicleId] ASC,
			[EnterTime] ASC
		)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


		/*SET variables*/
		SET @periodLength = 1
		SET @timezone = [dbo].[UserPref](@luid, 600)
		SET @s_date = @lsdate
		SET @e_date = @ledate
		SET @lsdate = [dbo].[TZ_ToUTC] (@lsdate,default,@luid)
		SET @ledate = [dbo].[TZ_ToUTC] (@ledate,default,@luid)

		/*INSERT variables*/
		--PRINT 'Insert data: ' + CONVERT(NVARCHAR(MAX), GETDATE(), 120)
		INSERT INTO @vintids (VehicleId, VehicleIntId)
		SELECT DISTINCT VehicleId, VehicleIntId
		FROM dbo.Vehicle
		WHERE VehicleId IN (SELECT VALUE FROM dbo.Split(@lvids, ',')) AND Archived = 0
		
		------INSERT INTO #geotab (GeofenceId, WKB, CentreLat, CentreLon)
		--------SELECT g.GeofenceId, ST.Envelope(g.the_geom), g.CenterLat, g.CenterLon
		------SELECT g.GeofenceId, NULL, g.CenterLat, g.CenterLon
		------FROM Geofence g
		------WHERE g.Archived = 0
		------	AND g.Enabled = 1
		------	AND g.GeofenceId IN (SELECT value FROM dbo.Split(@lgeofenceids,','))
		
		INSERT INTO #vehtab (VehicleId, VehicleIntId, StartDate, EndDate)
		SELECT DISTINCT VehicleId, VehicleIntId, StartDate, EndDate
		FROM dbo.Vehicle,
			dbo.CreateDateRange(@lsdate, @ledate, @periodLength)
		WHERE VehicleId IN (SELECT VALUE FROM dbo.Split(@lvids, ',')) AND Archived = 0
		
		INSERT INTO #data( VehicleId ,VehicleIntId ,EventDateTime ,CreationCodeId ,Lat ,Long)
		SELECT v.VehicleId, e.VehicleIntId, e.EventDateTime, e.CreationCodeId, e.Lat, e.Long
		FROM dbo.Event e WITH (NOLOCK)
			INNER JOIN @vintids v ON e.VehicleIntId = v.VehicleIntId
			--INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
		WHERE e.VehicleIntId = v.VehicleIntId
			AND e.EventDateTime BETWEEN @lsdate AND @ledate
			AND e.Lat != 0 AND e.Long != 0
			AND e.CreationCodeId IN (1,2,5,10,29,101) -- reduce analysis to significant events for linestring creation
		ORDER BY e.VehicleIntId, e.EventDateTime
		
		-- PRINT 'Build line strings: ' + CONVERT(NVARCHAR(MAX), GETDATE(), 120)
		
		DECLARE veh_cur CURSOR FAST_FORWARD FOR
		SELECT VehicleId, VehicleIntId, StartDate, EndDate
		FROM #vehtab
		
		DECLARE @tmp int
			
		OPEN veh_cur
		FETCH NEXT FROM veh_cur INTO @vid, @vintid, @lsdate_period, @ledate_period
		WHILE @@FETCH_STATUS = 0
		BEGIN	
		
			-- Determine whether we should bother building this linestring
			SELECT @mindatetime = MIN(d.EventDateTime), @maxdatetime = MAX(d.EventDateTime)
			FROM #data d
			WHERE d.VehicleIntId = @vintid 
				AND d.EventDateTime BETWEEN @lsdate_period AND @ledate_period
		
			SET @build = NULL
			SELECT TOP 1 @build = 1 
			FROM #data d
			INNER JOIN dbo.Geofence g ON dbo.DistanceBetweenPoints(d.Lat, d.Long, g.CenterLat, g.CenterLon) < (@periodlength * 15)
			WHERE d.VehicleIntId = @vintid 
				AND d.EventDateTime IN (@mindatetime, @maxdatetime)
				AND g.GeofenceId IN (SELECT value FROM dbo.Split(@geofenceIds, ','))
		
			IF @build IS NOT NULL
			BEGIN
				SET @lineString = NULL
				SET @linestring_wkt = 'LINESTRING('
				
				SELECT @linestring_wkt = COALESCE(@linestring_wkt, ',', '') + CAST(Long AS NVARCHAR(MAX)) + ' ' + CAST(Lat AS NVARCHAR(MAX)) + ',' 
				FROM #data e
				WHERE VehicleIntId = @vintid AND EventDateTime BETWEEN @lsdate_period AND @ledate_period
		--		ORDER BY EventDateTime
				
				SET @linestring_wkt = REPLACE(@linestring_wkt + ')', ',)', ')')
				
				--PRINT @linestring_wkt
				
				IF LEN(@linestring_wkt) > 30
				BEGIN
					--SET @lineString = ST.LineFromText(@linestring_wkt,4326) 	
					--SET @lineString = NULL
					UPDATE #vehtab
					SET LineString = geometry::STGeomFromText(@linestring_wkt, 4326).MakeValid()
					WHERE VehicleIntId = @vintid
						AND StartDate = @lsdate_period
						AND EndDate = @ledate_period
				END
			END
			FETCH NEXT FROM veh_cur INTO @vid, @vintid, @lsdate_period, @ledate_period
		END
		CLOSE veh_cur
		DEALLOCATE veh_cur

		DELETE
		FROM #vehtab
		WHERE LineString IS NULL	
		
		--PRINT 'Finished Building line strings: ' + CONVERT(NVARCHAR(MAX), GETDATE(), 120)

		INSERT INTO #tbl_results ( VehicleId, VehicleIntId, GeofenceId, wkb, EnterTime, GeomType, CreationCodeId, EventDateTime ) 
		SELECT DISTINCT v.VehicleId, e.VehicleIntId, g.GeofenceId, NULL, dbo.TZ_GetTime(e.EventDateTime, @timezone, @luid), 
						CASE WHEN geometry::STPointFromText('POINT('+ CAST(Long AS NVARCHAR(30)) + ' '+ CAST(Lat AS NVARCHAR(30)) + ')', 4326).STWithin(g.the_geom) = 1 THEN 'I' ELSE 'O' END, 
						e.creationcodeid, e.EventDateTime 
		FROM #data e 
		INNER JOIN #vehtab v ON e.VehicleIntId = v.VehicleIntId AND e.EventDateTime BETWEEN v.StartDate AND v.EndDate	
		--INNER JOIN dbo.Geofence g ON geometry::STGeomFromText(v.Linestring, 4326).STCrosses(g.the_geom) = 1
		INNER JOIN dbo.Geofence g ON v.Linestring.STCrosses(g.the_geom) = 1

			--AND geometry::STPointFromText('POINT('+ CAST(gc.Long AS NVARCHAR(30)) + ' '+ CAST(gc.Lat AS NVARCHAR(30)) + ')', 4326).STWithin(the_geom) = 1


		------INNER JOIN #geotab g ON g. --ST.Crosses(v.LineString, g.WKB) = 1 OR ST.CoveredBy(v.LineString, g.WKB) = 1
		WHERE g.GeofenceId IN (SELECT value FROM dbo.Split(@geofenceIds, ',')) 

		--PRINT 'Finished Inserting into #tbl_results: ' + CONVERT(NVARCHAR(MAX), GETDATE(), 120)

		SELECT d.VehicleId, d.GeoFenceId, d.GeomType, min(d.EnterTime) as Entry,
			g.Name AS Geofencename, 
			g.GeofenceCategoryId AS Geofencecategory, 
			g.GeofenceTypeId AS GeofenceType, 
			NULL AS Note,
			v.Registration
		FROM
			(
			SELECT VehicleId, GeoFenceId, GeomType, EnterTime, ROW_NUMBER() 
				OVER(PARTITION BY GeoFenceId ORDER BY VehicleId, GeoFenceId, EnterTime) - ROW_NUMBER() 
				OVER(PARTITION BY GeoFenceId, GeomType ORDER BY VehicleId, GeofenceId, EnterTime) as Grp
			FROM #tbl_results 
			) d
			INNER JOIN dbo.Vehicle v ON v.VehicleId = d.VehicleId
			LEFT OUTER JOIN dbo.Geofence g ON g.GeofenceId = d.GeofenceId
		GROUP BY d.VehicleId, d.GeoFenceId, d.GeomType, d.grp, g.Name, g.GeofenceCategoryId, g.GeofenceTypeId, v.Registration
		ORDER BY d.VehicleId, d.GeoFenceId, Entry

		/*
		public Nullable<System.DateTime> DateEnteredGeofence { get; set; }
		public Nullable<System.DateTime> DateLeftGeofence { get; set; }
		public string TimeSpentInGeofenceText { get; set; }
		public Nullable<int> TimeSpentInGeofence { get; set; }
		*/

	--	PRINT 'Finished selecting final result set: ' + CONVERT(NVARCHAR(MAX), GETDATE(), 120)

		DROP TABLE #data
		DROP TABLE #tbl_results
		DROP TABLE #vehtab
		--DROP TABLE #geotab

		--PRINT 'Done: ' + CONVERT(NVARCHAR(MAX), GETDATE(), 120)
		
		-- Now the compiler knows these things exist so we can set FMTONLY back to its original status
		IF @fmtonlyON = 1 BEGIN SET FMTONLY ON END

GO
