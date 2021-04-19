SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_GetDailyDriverLogonsByUser]
(
	@VehicleId UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME = NULL
)
AS

--DECLARE @vehicleid UNIQUEIDENTIFIER,
--		@uid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME,
--		@depid INT
		
--SET @VehicleId = N'949324B2-FF57-444D-95FB-39E7FA4BAA4E'
--SET @sdate = '2016-07-11 00:00'
--SET @edate = '2016-07-14 23:10:49.000'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

DECLARE @s_date DATETIME,
		@e_date DATETIME,
		@timezone nvarchar(30),
		@fobLogonCount INT,
		@ccidToCheck INT

DECLARE @results TABLE
(
	VehicleId UNIQUEIDENTIFIER,
	DriverId UNIQUEIDENTIFIER,
	CreationCodeId SMALLINT,
	EventDateTime DATETIME,
	DriverName VARCHAR(255),
	DriverNumber VARCHAR(50), 
	EventId BIGINT,
	DepotId INT,
	OdoGPS INT, 
	OdoDashboard INT, 
	OdoRoadSpeed INT
)

DECLARE @VehicleIntId INT
IF @VehicleId IS NOT NULL
	SET @VehicleIntId = dbo.GetVehicleIntFromId(@VehicleId)
	
-- Dummy result set for Codesmith (which runs with "SET FMTONLY ON").
IF @vehicleid IS NULL AND @uid IS NULL AND @sdate IS NULL AND @edate IS NULL
BEGIN
	SELECT VehicleId ,
           DriverId ,
           CreationCodeId ,
           EventDateTime ,
           DriverName ,
           DriverNumber ,
           EventId ,
           DepotId,
		   OdoGPS, 
		   OdoDashboard, 
		   OdoRoadSpeed
	FROM @results
	return
END

IF @edate IS NULL
BEGIN
	SET @edate = DateAdd( second, -1, DateAdd(day, 1, @sdate))
END

SET @sdate = DATEADD(DAY, -1, @sdate)

SET @timeZone = dbo.UserPref( @uid, 600 )
SET @s_date = dbo.TZ_ToUtc(@sdate,@timezone,@uid)
SET @e_date = dbo.TZ_ToUtc(@edate,@timezone,@uid)



SELECT @fobLogonCount = COUNT(DriverIntId)
FROM [dbo].Event e
WHERE e.VehicleIntId = @VehicleIntId
AND e.CreationCodeId = 61
AND e.EventDateTime BETWEEN @s_date AND @e_date


IF @fobLogonCount > 0
	SET @ccidToCheck = 61
ELSE
	SET @ccidToCheck = 0

DECLARE @IVHDriverIdType INT
SELECT TOP 1 @IVHDriverIdType = it.DriverIdType
FROM dbo.Vehicle v
	INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
	INNER JOIN dbo.IVHType it ON it.IVHTypeId = i.IVHTypeId
WHERE v.VehicleId = @vehicleid
ORDER BY v.LastOperation DESC

IF @IVHDriverIdType = 2
BEGIN
	INSERT INTO @results
	        ( VehicleId ,
	          DriverId ,
	          CreationCodeId ,
	          EventDateTime ,
	          DriverName ,
	          DriverNumber ,
	          EventId ,
	          DepotId ,
	          OdoGPS ,
	          OdoDashboard ,
	          OdoRoadSpeed
	        )
	SELECT @VehicleId AS VehicleId, d.DriverId, 61 as CreationCodeId, 
		   dbo.TZ_GetTime( e.EventDateTime, @timezone, @uid) AS EventDateTime, 
		   ISNULL(d.Surname,'') + ' ' + ISNULL(d.FirstName,'') AS DriverName,  
		   d.Number AS DriverNumber, 
		   e.EventId, 
		   e.CustomerIntId AS DepotId,
		   e.OdoGPS, e.OdoDashboard, e.OdoRoadSpeed
	FROM [dbo].[Event] e 
		INNER JOIN dbo.CreationCode cc ON e.CreationCodeId = cc.CreationCodeId
		INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
		LEFT OUTER JOIN dbo.[EventData] ed ON e.EventId = ed.EventId AND e.VehicleIntId = ed.VehicleIntId
		INNER JOIN [dbo].[Driver] d ON e.DriverIntId = d.DriverIntId
	WHERE e.VehicleIntId = @VehicleIntId
	  AND e.EventDateTime BETWEEN @s_date AND @e_date
	  AND ed.EventDataName = 'DID'
	  AND e.CreationCodeId = 0
	  --CreateionCodeId = 61 is a logout
	--ORDER BY e.EventDateTime ASC
END
ELSE
BEGIN
	INSERT INTO @results
	        ( VehicleId ,
	          DriverId ,
	          CreationCodeId ,
	          EventDateTime ,
	          DriverName ,
	          DriverNumber ,
	          EventId ,
	          DepotId ,
	          OdoGPS ,
	          OdoDashboard ,
	          OdoRoadSpeed
	        )
	SELECT @VehicleId AS VehicleId, d.DriverId, 61 as CreationCodeId, 
		   dbo.TZ_GetTime( e.EventDateTime, @timezone, @uid) AS EventDateTime, 
		   ISNULL(d.Surname,'') + ' ' + ISNULL(d.FirstName,'') AS DriverName,  
		   d.Number AS DriverNumber, 
		   e.EventId, 
		   e.CustomerIntId AS DepotId,
		   e.OdoGPS, e.OdoDashboard, e.OdoRoadSpeed
	FROM [dbo].[Event] e 
		INNER JOIN dbo.CreationCode cc ON e.CreationCodeId = cc.CreationCodeId
		INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
		--LEFT OUTER JOIN dbo.[EventData] ed ON e.EventId = ed.EventId AND e.VehicleIntId = ed.VehicleIntId
		INNER JOIN [dbo].[Driver] d ON e.DriverIntId = d.DriverIntId
	WHERE e.VehicleIntId = @VehicleIntId
	  AND e.EventDateTime BETWEEN @s_date AND @e_date
	  AND e.CreationCodeId = 61
	  AND e.OdoGPS != 0
	--ORDER BY e.EventDateTime ASC
END


SELECT VehicleId ,
       DriverId ,
       CreationCodeId ,
       EventDateTime ,
       DriverName ,
       DriverNumber ,
       EventId ,
       DepotId ,
       OdoGPS ,
       OdoDashboard ,
       OdoRoadSpeed
FROM @results
ORDER BY EventDateTime ASC

GO
