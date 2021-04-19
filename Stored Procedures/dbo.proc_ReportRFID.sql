SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportRFID]
(
	@vids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE	@vids varchar(max),
--		@sdate datetime,
--		@edate datetime,
--		@uid UNIQUEIDENTIFIER
--
--SET @vids = N'FF19700E-A677-49CD-B353-34F2BC5A1FD0,19F54EC5-6CCA-47E3-A63D-861419DD626C'
--SET @sdate = '2013-10-16 00:00'
--SET @edate = '2013-11-17 23:59'
--SET @uid = N'5A183811-A76E-43E3-91A3-8CD60AF55EF3' 

DECLARE	@lvids varchar(max),
		@lsdate datetime,
		@ledate datetime,
		@luid UNIQUEIDENTIFIER
		
SET @lvids = @vids
SET @lsdate = @sdate
SET @ledate = @edate
SET @luid = @uid

SET @lsdate = [dbo].TZ_ToUTC(@lsdate,default,@luid)
SET @ledate = [dbo].TZ_ToUTC(@ledate,default,@luid)

DECLARE @results TABLE
(
	VehicleId UNIQUEIDENTIFIER,
	Registration NVARCHAR(MAX),
	
	DriverId UNIQUEIDENTIFIER,
	Number NVARCHAR(MAX),
	DriverName NVARCHAR(MAX),
	
	EventId BIGINT,
    EventDataName NVARCHAR(MAX),
    EventDataString NVARCHAR(MAX),
    RFIDGrouped NVARCHAR(MAX),
    
    CreationCodeId INT,
    Speed INT,
    Heading INT,
    Lat FLOAT,
    Long FLOAT,
    ReverseGeoCode NVARCHAR(MAX),
    EventDateTime DATETIME,
    
	CreationDateTime DATETIME,
	ClosureDateTime DATETIME
)
INSERT INTO @results
        ( VehicleId ,
          Registration ,
          DriverId ,
          Number ,
          DriverName ,
          EventId ,
          EventDataName ,
          EventDataString ,
          RFIDGrouped ,
          CreationCodeId ,
          Speed ,
          Heading ,
          Lat ,
          Long ,
          ReverseGeoCode ,
          EventDateTime ,
          CreationDateTime ,
          ClosureDateTime
        )
SELECT	v.VehicleId,
		v.Registration,
		
		d.DriverId,
		d.Number,
		d.Surname AS DriverName,
		
		e.EventId,
		ed.EventDataName,
		dbo.TrimLeftRightNonAlphaNumerics(ed.EventDataString) AS EventDataString,
		NULL AS RFIDGrouped,
		e.CreationCodeId,
		e.Speed,
		e.Heading,
		e.Lat,
		e.Long,
		[dbo].[GetGeofenceNameFromLongLat] (e.Lat, e.Long, @luid, [dbo].[GetAddressFromLongLat] (e.Lat, e.Long)) as ReverseGeoCode,
		[dbo].TZ_GetTime(e.EventDateTime,default,@luid) AS EventDateTime,
		
		[dbo].TZ_GetTime(@lsdate,default,@luid) AS CreationDateTime,
		[dbo].TZ_GetTime(@ledate,default,@luid) AS ClosureDateTime
FROM dbo.Event e
	INNER JOIN dbo.EventData ed ON e.EventId = ed.EventId AND e.VehicleIntId = ed.VehicleIntId
	INNER JOIN dbo.Driver d ON e.DriverIntId = d.DriverIntId
	INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
WHERE v.VehicleId IN (SELECT Value FROM dbo.Split(@lvids, ','))
	AND e.EventDateTime BETWEEN @lsdate AND @ledate
	AND e.CreationCodeId = 66
	AND ed.EventId NOT IN (27498882,27498883,27498884)
	AND e.Archived = 0
	
SELECT	  VehicleId ,
          Registration ,
          DriverId ,
          Number ,
          DriverName ,
          EventId ,
          EventDataName ,
		  CASE WHEN CHARINDEX(',', EventDataString) = 0 
			THEN EventDataString 
			ELSE SUBSTRING(EventDataString, 0, CHARINDEX(',', EventDataString)) 
		  END AS RageId,
		  CASE WHEN CHARINDEX(',', EventDataString) = 0 
			THEN 'N/A' 
			ELSE SUBSTRING(EventDataString, CHARINDEX(',', EventDataString) + 1, LEN(EventDataString)) 
		  END AS AntennaId,
--        RageId ,
--          CASE WHEN AntennaId = '' 
--			THEN '--' 
--			ELSE AntennaId--dbo.TrimLeftRightNonAlphaNumerics(AntennaId)
--		  END AS AntennaId ,
          RFIDGrouped ,
          CreationCodeId ,
          Speed ,
          Heading ,
          Lat ,
          Long ,
          ReverseGeoCode ,
          EventDateTime ,
          CreationDateTime ,
          ClosureDateTime
FROM @results
ORDER BY EventDateTime DESC

GO
