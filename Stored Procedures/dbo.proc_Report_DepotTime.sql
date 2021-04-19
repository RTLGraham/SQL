SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_DepotTime]
	@uid      UNIQUEIDENTIFIER,
    @gids     NVARCHAR(MAX),
    @dids     NVARCHAR(MAX),
    @sdate    DATETIME,
    @edate    DATETIME,
	@vch	  BIT,
	@other	  BIT,
	@exclude  BIT	
AS

	SET NOCOUNT ON;
	
	--DECLARE	@uid      UNIQUEIDENTIFIER,
	--		@gids     NVARCHAR(MAX),
	--		@dids     NVARCHAR(MAX),
	--		@sdate    DATETIME,
	--		@edate    DATETIME,
	--		@vch	  BIT,
	--		@other	  BIT,
	--		@exclude  BIT	

	--SET @dids = N'7552DD57-2E15-4980-80D9-10C9DF5ED1C7,8BB30CB0-933A-4833-9FC3-163732F2FA2F,54268AAC-E6E5-41C8-98B0-17594DA54800,B16A7BA1-6503-46E6-8B8E-2F2F83931D17,4ED002DC-180E-4B51-BB0F-358D92391159,98DB0E28-E8D8-4A1B-BB6C-4CFC9C645250,A5773C2F-21FF-4B4B-AFB4-53A83A1F839F,9854721D-7CF3-47A4-90B8-56E148DFC694,BDD8137F-4C50-4A9B-8E95-5A35D94813CD,4F34516F-9674-4A60-9C33-5FF0A1B51E51,E75EF09A-D9B0-425A-BB07-663135024488,638AEFE8-6CDA-4EFF-9E28-698EB8AA8982,E32C0085-6ED0-486A-B67F-6F7B7F8AF091,7C1C5408-E8BE-4707-9C8C-7FEC08434947,A27ED711-C033-478C-9689-817FEF2DAC79,598F8D62-0B34-4CBF-A4AE-91A9358F4E72,CD8F2681-D0AE-4466-946D-A8A6E7B57AE9,C38F5207-D209-4A14-A291-AF9DDDE69B4B,AC9104BD-76E0-476F-8DA7-D817DDEB9F31,F4AF34DD-25A9-4BB3-B10E-E88B92EC66CF,E179369C-203B-4B1E-9C11-EF4B00A96528,7FB2EA17-4F26-4D65-9209-F3F7D1C73A19,539EB10F-A2DA-4ECB-BBFC-FCC2AA9FA333'
	--SET @gids = N'818AFD3A-DC45-4042-93FB-870472DFFB0C'--NULL--N'1B5600D4-85AE-4A78-B071-2EE555EB3300,843EEAB8-EC94-4923-8327-402B09F64F1F,5E9679AC-1B6F-4700-97E8-53BB46B0BC01,0D572BAC-D832-4D53-A192-7F7C56E1D37B,98E7ECE2-6AA1-41D9-BAA9-8B9CAB5D5FD2,983AEB57-6600-42C3-BA24-8D307F5AD57F,BB3428A6-B8A5-4E7A-A081-99806369285F,071410D1-1B88-40E7-8D81-ADE51D9683E9,26C8A9B2-2EB9-49A1-8C8D-DFBA04C697C3,0071EDE5-3222-4A5F-A00C-EB679C17B6FC,51D84E06-84FB-451C-8A02-F86F0219C39A'
	--SET @sdate = '2020-11-18 00:00'
	--SET @edate = '2020-11-18 23:59'
	--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
	--SET @vch = 1
	--SET @other = 1
	--SET @exclude = 0

	DECLARE @s_date DATETIME,
			@e_date DATETIME,
			@stime TIME,
			@etime TIME,
			@isOneDay BIT      
 
	-- Set 'real' departure and return time limits
	-- Use today's date by default so that DST time conversion is applied properly
	SET @stime = dbo.TZ_TimeToUtc('05:00', NULL, DEFAULT, @uid)
	SET @etime = dbo.TZ_TimeToUtc('20:00', NULL, DEFAULT, @uid)
		
	IF @sdate = @edate SET @edate = DATEADD(mi, 1439, @sdate)	
	--SET @s_date = @sdate
	--SET @e_date = @edate
	SET @sdate = dbo.TZ_ToUtc(@sdate, DEFAULT, @uid)
	SET @edate = dbo.TZ_ToUtc(@edate, DEFAULT, @uid) 

 	-- Determine if the report is running for one, or multiple, days
	SELECT @isOneDay = CASE WHEN DATEDIFF(mi, @sdate, @edate) > 1439 THEN 0 ELSE 1 END	

	-- Create a temporary table for real geofence exits / entries for the required vehicles
	-- Insert one row per day, driver, geofence combination taking the earliest exit and latest entry, with total exit duration
	DECLARE @RealDriverTrips TABLE
	(
		DateNum FLOAT,
		DriverIntId INT,
		GeofenceId UNIQUEIDENTIFIER,
		ExitDateTime DATETIME,
		ExitEventId BIGINT,
		EntryDateTime DATETIME,
		EntryEventId BIGINT,
		ExitSeconds BIGINT
	)

	INSERT INTO @RealDriverTrips (DateNum, DriverIntId, GeofenceId, ExitDateTime, ExitEventId, EntryDateTime, EntryEventId, ExitSeconds)
	SELECT DISTINCT FLOOR(CAST(gexit.ExitDateTime AS FLOAT)), gexit.ExitDriverIntId AS DriverIntId, gexit.GeofenceId AS GeofenceId, MIN(gexit.ExitDateTime), MIN(gexit.ExitEventId), MAX(gentry.EntryDateTime), MAX(gentry.EntryEventId), SUM(DATEDIFF(ss, gexit.ExitDateTime, gentry.EntryDateTime)) AS ExitSeconds
	FROM
		(SELECT ROW_NUMBER() OVER (PARTITION BY VehicleIntId, vgh.GeofenceId ORDER BY EntryDateTime) AS RowNum, vgh.*
		FROM dbo.VehicleGeofenceHistory vgh
		INNER JOIN dbo.Geofence geo ON geo.GeofenceId = vgh.GeofenceId AND geo.IsTemperatureMonitored = 1
		WHERE EntryDateTime BETWEEN @sdate AND @edate OR ExitDateTime BETWEEN @sdate AND @edate
		  ) gexit	  
	INNER JOIN 
		(SELECT ROW_NUMBER() OVER (PARTITION BY VehicleIntId, vgh.GeofenceId ORDER BY EntryDateTime) AS RowNum, vgh.*
		FROM dbo.VehicleGeofenceHistory vgh
		INNER JOIN dbo.Geofence geo ON geo.GeofenceId = vgh.GeofenceId AND geo.IsTemperatureMonitored = 1
		WHERE EntryDateTime BETWEEN @sdate AND @edate OR ExitDateTime BETWEEN @sdate AND @edate
		  ) gentry ON gexit.VehicleIntId = gentry.VehicleIntId AND gexit.GeofenceId = gentry.GeofenceId AND gentry.RowNum = gexit.RowNum + 1	  
	INNER JOIN dbo.Driver d ON d.DriverIntId = gexit.ExitDriverIntId
	WHERE DATEDIFF(ss, gexit.ExitDateTime, gentry.EntryDateTime) BETWEEN 2700 AND 43200 -- Real trips are between 30mins and 12 hours in duration
	  AND CAST(gexit.ExitDateTime AS TIME) > @stime
	  AND CAST(gentry.EntryDateTime AS TIME) < @etime
	  AND d.DriverId IN (SELECT VALUE FROM dbo.Split(@dids, ','))
	GROUP BY FLOOR(CAST(gexit.ExitDateTime AS FLOAT)), gexit.ExitDriverIntId, gexit.GeofenceId

	DECLARE @driverdata TABLE
	(
		DayNum FLOAT,
		DriverId UNIQUEIDENTIFIER,
		groupId UNIQUEIDENTIFIER,
		Route INT,
		Morning INT,
		Afternoon INT,
		TelematTime INT,
		KRONOSTime INT,
		OtherJob INT,
		TelematTotal INT,
		Total INT,
		KRONOSArrival DATETIME,
		GeofenceLeave DATETIME,
		GeofenceEnter DATETIME,
		KRONOSDepart DATETIME
	)

	-- Select the data for the individual drivers
	-- Calculations for KRONOSTime and Total amended so as not to use Exit Seconds as mutiple trips / non 'real' trips cause calculation discrepancies 
	-- Further modified so as not to include break time between first out and second in, if present 
	INSERT INTO @driverdata (DayNum, DriverId, GroupId, Route, Morning, Afternoon, TelematTime, KRONOSTime, OtherJob, TelematTotal, Total, KRONOSArrival, GeofenceLeave, GeofenceEnter, KRONOSDepart)
	SELECT DISTINCT	
		CAST(k.KronosDate AS FLOAT),
		d.DriverId,
		g.GroupId,
		--ISNULL(CAST(t.ExitSeconds AS INT),0) AS Route,
		ISNULL(DATEDIFF(SECOND, t.ExitDateTime, t.EntryDateTime), 0) AS Route,
		ISNULL(DATEDIFF(ss, k.FirstIn, t.ExitDateTime), 0) AS Morning,
		ISNULL(DATEDIFF(ss, t.EntryDateTime, ISNULL(k.SecondOut, k.FirstOut)), 0) AS Afternoon,
		CASE WHEN ISNULL(CAST(t.ExitSeconds AS INT),0) = 0 THEN 0 ELSE ISNULL(DATEDIFF(ss, k.FirstIn, t.ExitDateTime),0) + ISNULL(DATEDIFF(ss, t.EntryDateTime, ISNULL(k.SecondOut, k.FirstOut)),0) END AS TelematTime,
		--CASE WHEN d.DriverType = 'VCH' OR (d.DriverType = 'OTHER' AND ISNULL(CAST(t.ExitSeconds AS INT),0) > 0) THEN ISNULL(DATEDIFF(ss, k.FirstIn, k.FirstOut), 0) + ISNULL(DATEDIFF(ss, k.SecondIn, k.SecondOut), 0) - ISNULL(CAST(t.ExitSeconds AS INT),0) ELSE 0 END AS KRONOSTime,
		CASE WHEN d.DriverType = 'VCH' OR (d.DriverType = 'OTHER' AND ISNULL(CAST(t.ExitSeconds AS INT),0) > 0) THEN ISNULL(DATEDIFF(ss, k.FirstIn, ISNULL(k.SecondOut, k.FirstOut)), 0) - ISNULL(DATEDIFF(ss, t.ExitDateTime, t.EntryDateTime), 0) END AS KRONOSTime,
		ISNULL(j.OtherJob * 60,0) AS OtherJob,
		CASE WHEN ISNULL(CAST(t.ExitSeconds AS INT),0) = 0 THEN 0 ELSE ISNULL(DATEDIFF(ss, k.FirstIn, t.ExitDateTime),0) + ISNULL(DATEDIFF(ss, t.EntryDateTime, ISNULL(k.SecondOut, k.FirstOut)),0) - ISNULL(j.OtherJob * 60, 0) END AS TelematTotal,
		--CASE WHEN d.DriverType = 'VCH' OR (d.DriverType = 'OTHER' AND ISNULL(CAST(t.ExitSeconds AS INT),0) > 0) THEN ISNULL(DATEDIFF(ss, k.FirstIn, k.FirstOut), 0) + ISNULL(DATEDIFF(ss, k.SecondIn, k.SecondOut), 0) - ISNULL(CAST(t.ExitSeconds AS INT),0) - ISNULL(j.OtherJob,0) ELSE 0 END AS Total,
		--CASE WHEN d.DriverType = 'VCH' OR (d.DriverType = 'OTHER' AND ISNULL(CAST(t.ExitSeconds AS INT),0) > 0) THEN ISNULL(DATEDIFF(ss, k.FirstIn, k.FirstOut), 0) + ISNULL(DATEDIFF(ss, k.SecondIn, k.SecondOut), 0) - ISNULL(DATEDIFF(ss, t.ExitDateTime, t.EntryDateTime), 0) - ISNULL(j.OtherJob,0) ELSE 0 END AS Total,
		CASE WHEN d.DriverType = 'VCH' OR (d.DriverType = 'OTHER' AND ISNULL(CAST(t.ExitSeconds AS INT),0) > 0) THEN ISNULL(DATEDIFF(ss, k.FirstIn, ISNULL(k.SecondOut, k.FirstOut)), 0) - ISNULL(DATEDIFF(ss, t.ExitDateTime, t.EntryDateTime), 0) - ISNULL(j.OtherJob * 60, 0) ELSE 0 END AS Total,
		CASE WHEN @isOneDay = 0 THEN NULL ELSE k.FirstIn END,
		CASE WHEN @isOneDay = 0 THEN NULL ELSE t.ExitDateTime END,
		CASE WHEN @isOneDay = 0 THEN NULL ELSE t.EntryDateTime END,
		CASE WHEN @isOneDay = 0 THEN NULL ELSE ISNULL(k.SecondOut, k.FirstOut) END	

	FROM dbo.Driver d
	INNER JOIN dbo.Kronos k ON d.DriverIntId = k.DriverIntId
	INNER JOIN dbo.GroupDetail gd ON d.DriverId = gd.EntityDataId
	INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
	LEFT JOIN @RealDriverTrips t ON t.DriverIntId = d.DriverIntId AND k.KronosDate = CAST(t.DateNum AS SMALLDATETIME)
	LEFT JOIN (SELECT ka.DriverId, FLOOR(CAST(ka.Date AS FLOAT)) AS DateNum, SUM(ka.Duration) AS OtherJob
				FROM dbo.KronosAbsense ka
				WHERE ka.DriverId IN (SELECT value FROM dbo.Split(@dids, ','))
				  AND ka.Date BETWEEN @sdate AND @edate
				  AND ka.Archived = 0
				GROUP BY ka.DriverId, FLOOR(CAST(ka.Date AS FLOAT))
				) j ON j.DriverId = d.DriverId AND k.KronosDate = CAST(j.DateNum AS SMALLDATETIME)
	WHERE d.DriverId IN (SELECT value FROM dbo.Split(@dids, ','))
	  AND g.GroupId IN (SELECT value FROM dbo.Split(@gids, ','))
	  AND k.KronosDate BETWEEN @sdate AND @edate
	  AND ((ISNULL(@vch,1) = 1 AND d.DriverType = 'VCH') OR (ISNULL(@other,1) = 1 AND d.DriverType = 'OTHER') OR (ISNULL(@exclude,1) = 1 AND d.DriverType = 'EXCLUDE'))

	-- If any data is negative due to incorrect login/out then set it to NULL to mark as an error and exclude from averages
	UPDATE @driverdata
	SET Route = NULL 
	WHERE Route <= 0

	UPDATE @driverdata
	SET Morning = NULL 
	WHERE Morning <= 0

	UPDATE @driverdata
	SET Afternoon = NULL 
	WHERE Afternoon <= 0

	UPDATE @driverdata
	SET TelematTime = NULL 
	WHERE TelematTime <= 0

	UPDATE @driverdata
	SET KRONOSTime = NULL 
	WHERE KRONOSTime <= 0

	UPDATE @driverdata
	SET OtherJob = NULL 
	WHERE OtherJob <= 0

	UPDATE @driverdata
	SET TelematTotal = NULL 
	WHERE TelematTotal <= 0

	UPDATE @driverdata
	SET Total = NULL 
	WHERE Total <= 0

	DECLARE @results TABLE
	(
		RecordNr INT,
		AssetName NVARCHAR(MAX),
		DriverType NVARCHAR(MAX),
		AssetGroupID UNIQUEIDENTIFIER,
		AssetID UNIQUEIDENTIFIER,
		AssetType INT,
		Route INT,
		Morning INT,
		Afternoon INT,
		TelematTime INT,
		KRONOSTime INT,
		OtherJob INT,
		TelematTotal INT,
		Total INT,
		KRONOSArrival DATETIME,
		GeofenceLeave DATETIME,
		GeofenceEnter DATETIME,
		KRONOSDepart DATETIME
	)

	-- Now insert the driver data into the results table, providing one row per driver
	INSERT INTO @results (RecordNr, AssetName, DriverType, AssetGroupID, AssetID, AssetType, Route, Morning, Afternoon, TelematTime, KRONOSTime, OtherJob, TelematTotal, Total, KRONOSArrival, GeofenceLeave, GeofenceEnter, KRONOSDepart)
	SELECT	3 AS RecordNr,
			dbo.FormatDriverNameByUser(d.DriverId, @uid) AS AssetName,
			d.DriverType,
			g.GroupId AS AssetGroupID,
			d.DriverId AS AssetID,
			2 AS AssetType,
			AVG(Route),
			AVG(Morning),
			AVG(Afternoon),
            AVG(TelematTime),
			AVG(KRONOSTime),
			AVG(OtherJob),
			AVG(TelematTotal),
			AVG(Total),
			MIN(dd.KRONOSArrival),
			MIN(dd.GeofenceLeave),
			MAX(dd.GeofenceEnter),
			MAX(dd.KRONOSDepart)
	FROM @driverdata dd
	INNER JOIN dbo.Driver d ON d.DriverId = dd.DriverId
	INNER JOIN dbo.GroupDetail gd ON d.DriverId = gd.EntityDataId
	INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
	WHERE g.GroupId IN (SELECT value FROM dbo.Split(@gids, ','))
	GROUP BY d.DriverId, d.DriverType, g.groupId

	-- Now calculate and insert group averages
	INSERT INTO @results (RecordNr, AssetName, DriverType, AssetGroupID, AssetID, AssetType, Route, Morning, Afternoon, TelematTime, KRONOSTime, OtherJob, TelematTotal, Total)
	  SELECT 2, g.GroupName, NULL, NULL, g.GroupId, 1, AVG(Route), AVG(Morning), AVG(Afternoon), AVG(TelematTime), AVG(KRONOSTime), AVG(OtherJob), AVG(TelematTotal), AVG(Total)
	  FROM @results r
	  INNER JOIN dbo.[Group] g ON r.AssetGroupID = g.GroupId
	  GROUP BY g.GroupId, g.GroupName

	-- Now calculate and insert fleet averages
	INSERT INTO @results (RecordNr, AssetName, DriverType, AssetGroupID, AssetID, AssetType, Route, Morning, Afternoon, TelematTime, KRONOSTime, OtherJob, TelematTotal, Total)
	  SELECT 1, 'Fleet', NULL, NULL, NULL, 0, AVG(Route), AVG(Morning), AVG(Afternoon), AVG(TelematTime), AVG(KRONOSTime), AVG(OtherJob), AVG(TelematTotal), AVG(Total)
	  FROM @results r
	  WHERE r.AssetID IS NOT NULL	

	-- Return the full result set (Datetime columns are in UTC so need converting to local time)
	SELECT RecordNr,
           AssetName,
           DriverType,
           AssetGroupID,
           AssetID,
           AssetType,
           ISNULL(Route, 0) AS Route,
           ISNULL(Morning, 0) AS Morning,
           ISNULL(Afternoon, 0) AS Afternoon,
           ISNULL(TelematTime, 0) AS TelematTime,
           ISNULL(KRONOSTime, 0) AS KRONOSTime,
           ISNULL(OtherJob, 0) AS OtherJob,
           --CASE WHEN ISNULL(TelematTotal, 0) = 0 THEN 0 ELSE ISNULL(TelematTotal, 0) - (ISNULL(OtherJob, 0) * 60) END AS TelematTotal,
		   ISNULL(TelematTotal, 0) AS TelematTotal,
           --ISNULL(Total, 0) - (ISNULL(OtherJob, 0) * 60) AS Total,
		   ISNULL(Total, 0) AS Total,
           dbo.TZ_GetTime(KRONOSArrival, DEFAULT, @uid) AS KRONOSArrival,
           dbo.TZ_GetTime(GeofenceLeave, DEFAULT, @uid) AS GeofenceLeave,
           dbo.TZ_GetTime(GeofenceEnter, DEFAULT, @uid) AS GeofenceEnter,
           dbo.TZ_GetTime(KRONOSDepart, DEFAULT, @uid) AS KRONOSDepart
	FROM @results



	

GO
