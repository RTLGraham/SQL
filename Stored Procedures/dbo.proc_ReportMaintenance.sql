SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportMaintenance]
    (
      @vids varchar(max),
      @sdate datetime,
      @edate datetime,
      @uid UNIQUEIDENTIFIER
    )
AS 
    SET NOCOUNT ON
	--DECLARE @vids varchar(max),
	--	@sdate datetime,
	--	@edate datetime,
	--	@uid uniqueidentifier

	--SET @vids = N'38B71A7E-53B1-E111-838A-0015173D1551,2109581B-A8B3-E111-838A-0015173D1551,0BC7F7E6-EEF0-E111-8D15-0015173D1551,0143C0A3-6F2E-E211-8D15-0015173D1551,A52E70A9-EBC4-E011-A26E-001C23C37503,A72E70A9-EBC4-E011-A26E-001C23C37503,A92E70A9-EBC4-E011-A26E-001C23C37503,AD2E70A9-EBC4-E011-A26E-001C23C37503,AF2E70A9-EBC4-E011-A26E-001C23C37503,B12E70A9-EBC4-E011-A26E-001C23C37503,B32E70A9-EBC4-E011-A26E-001C23C37503,B52E70A9-EBC4-E011-A26E-001C23C37503,B92E70A9-EBC4-E011-A26E-001C23C37503,BB2E70A9-EBC4-E011-A26E-001C23C37503,BF2E70A9-EBC4-E011-A26E-001C23C37503,C12E70A9-EBC4-E011-A26E-001C23C37503,C72E70A9-EBC4-E011-A26E-001C23C37503,C92E70A9-EBC4-E011-A26E-001C23C37503,CD2E70A9-EBC4-E011-A26E-001C23C37503,CF2E70A9-EBC4-E011-A26E-001C23C37503,D52E70A9-EBC4-E011-A26E-001C23C37503,D92E70A9-EBC4-E011-A26E-001C23C37503,DB2E70A9-EBC4-E011-A26E-001C23C37503,DF2E70A9-EBC4-E011-A26E-001C23C37503,E12E70A9-EBC4-E011-A26E-001C23C37503,E52E70A9-EBC4-E011-A26E-001C23C37503,E72E70A9-EBC4-E011-A26E-001C23C37503,E92E70A9-EBC4-E011-A26E-001C23C37503,ED2E70A9-EBC4-E011-A26E-001C23C37503,EF2E70A9-EBC4-E011-A26E-001C23C37503,F12E70A9-EBC4-E011-A26E-001C23C37503,F32E70A9-EBC4-E011-A26E-001C23C37503,F52E70A9-EBC4-E011-A26E-001C23C37503,F72E70A9-EBC4-E011-A26E-001C23C37503,F92E70A9-EBC4-E011-A26E-001C23C37503,FB2E70A9-EBC4-E011-A26E-001C23C37503,FD2E70A9-EBC4-E011-A26E-001C23C37503,A62FE015-C419-E111-A26E-001C23C37503,49DF5549-77BE-49B3-8D96-0085A48B5C38,C2AB6D79-553E-46D7-BB9A-01D653FADA0B,EA81A5EA-8DEC-4D9D-AE12-05290A3C842A,671D0F0B-64C9-43FC-A739-0C0999F4C45D,38D8492D-2547-4B63-8775-3B1F34F77188,CE09B0F9-99C9-4407-8292-42C50E3968C1,354F79DB-CB1C-491D-A3FD-6EC6BA785AC3,59677C9A-1568-4866-9081-7BEA174D556E,DCA616FD-5876-43A4-B3CC-8A430689E688,40A08396-8DFA-4697-BFDF-C6EE3B0DE481'
	--SET @sdate = GETDATE()
	--SET @edate = GETDATE()
	--SET @uid = N'047A1518-AF00-4E85-8F97-7DB701587DB9'
    
    DECLARE @diststr varchar(20),
        @distmult float,
        @fuelstr varchar(20),
        @fuelmult float,
        @co2str varchar(20),
        @co2mult FLOAT,
        @liquidstr varchar(20),
        @liquidmult float

    SELECT  @diststr = [dbo].UserPref(@uid, 203)
    SELECT  @distmult = [dbo].UserPref(@uid, 202)
    SELECT  @fuelstr = [dbo].UserPref(@uid, 205)
    SELECT  @fuelmult = [dbo].UserPref(@uid, 204)
    SELECT  @co2str = [dbo].UserPref(@uid, 211)
    SELECT  @co2mult = [dbo].UserPref(@uid, 210)
    SELECT  @liquidstr = [dbo].UserPref(@uid, 201)
    SELECT  @liquidmult = [dbo].UserPref(@uid, 200)

    SET @sdate = [dbo].TZ_ToUTC(@sdate, default, @uid)
    SET @edate = [dbo].TZ_ToUTC(@edate, default, @uid)
	
    DECLARE @offset DATETIME

    SET @offset = DATEADD(hour, -24, GETUTCDATE())

    DECLARE @results TABLE
        (
          VehicleId UNIQUEIDENTIFIER,
          Registration NVARCHAR(MAX),
          VehicleTypeID INT,
          DaysNotPolled INT,
          LastPoll DATETIME,
          PollLat FLOAT,
          PollLon FLOAT,
          PollLocation NVARCHAR(MAX),
          EventDateTime DATETIME,
          FirmwareVersion NVARCHAR(MAX),
          sdate DATETIME,
          edate DATETIME,
          CreationDateTime DATETIME,
          ClosureDateTime DATETIME,
          DistanceUnit NVARCHAR(MAX),
          FuelUnit NVARCHAR(MAX),
          LiquidUnit NVARCHAR(MAX),
          Co2Unit NVARCHAR(MAX)
        )
      
		INSERT INTO @results (VehicleId, Registration, VehicleTypeID, DaysNotPolled, LastPoll, PollLat, PollLon, PollLocation, EventDateTime, FirmwareVersion, sdate, edate, CreationDateTime, ClosureDateTime, DistanceUnit, FuelUnit, LiquidUnit, Co2Unit)    
		SELECT    v.VehicleId,
					v.Registration,
					v.VehicleTypeID,
					DATEDIFF(day, e.EventDateTime, GETUTCDATE()) AS DaysNotPolled,
					dbo.TZ_GetTime(e.EventDateTime, DEFAULT, @uid) AS LastPoll,
					e.Lat AS PollLat,
					e.Long AS PollLon,
					--dbo.GetAddressFromLongLat(e.Lat, e.Long) AS PollLocation,
					dbo.GetGeofenceNameFromLongLat (e.Lat, e.Long, @uid, dbo.GetAddressFromLongLat(e.Lat, e.Long)) as PollLocation,
					e.EventDateTime,
					i.FirmwareVersion,
					@sdate AS sdate,
					@edate AS edate,
					dbo.TZ_GetTime(@sdate, DEFAULT, @uid) AS CreationDateTime,
					dbo.TZ_GetTime(@edate, DEFAULT, @uid) AS ClosureDateTime,
					@diststr AS DistanceUnit,
					@fuelstr AS FuelUnit,
					@liquidstr AS LiquidUnit,
					@co2str AS Co2Unit
		  FROM      dbo.Vehicle v
					LEFT OUTER JOIN dbo.IVH i ON v.IVHId = i.IVHId
					INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
					INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
					INNER JOIN dbo.VehicleLatestEvent ev ON ev.VehicleId = v.VehicleId
					--INNER JOIN (SELECT evt.VehicleIntId, evt.CustomerIntId, MAX(evt.EventId) AS EventId
					--			FROM dbo.Event evt
					--				INNER JOIN dbo.Vehicle vv ON evt.VehicleIntId = vv.VehicleIntId
					--			WHERE evt.EventDateTime BETWEEN (SELECT TOP 1 vle.EventDateTime 
					--											 FROM dbo.VehicleLatestEvent vle
					--											 WHERE vle.VehicleId = vv.VehicleId) AND GETUTCDATE()
					--			GROUP BY evt.VehicleIntId, evt.CustomerIntId) ev ON
					--												 ev.VehicleIntId = v.VehicleIntId
					--												 AND ev.CustomerIntId = c.CustomerIntId
					INNER JOIN dbo.Event e ON ev.EventId = e.EventId												 
		  WHERE     v.VehicleId IN ( SELECT Value
									 FROM   dbo.Split(@vids, ',') )
					AND cv.Archived = 0 AND cv.EndDate IS NULL
    
    SELECT VehicleId,
          Registration,
          VehicleTypeID,
          DaysNotPolled,
          LastPoll,
          PollLat,
          PollLon,
          PollLocation,
          FirmwareVersion,
          sdate,
          edate,
          CreationDateTime,
          ClosureDateTime,
          DistanceUnit,
          FuelUnit,
          LiquidUnit,
          Co2Unit
    FROM @results
    WHERE EventDateTime <= @offset 
    ORDER BY DaysNotPolled DESC


GO
