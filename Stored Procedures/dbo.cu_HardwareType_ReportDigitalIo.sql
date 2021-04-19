SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_HardwareType_ReportDigitalIo]
(
	@vids NVARCHAR(MAX) = NULL, 
    @uid UNIQUEIDENTIFIER = NULL,
	@sdate DATETIME = NULL, 
	@edate DATETIME = NULL,
    @dios NVARCHAR(MAX) = NULL
)
AS

--DECLARE	@sdate DATETIME,
--		@edate DATETIME,
--		@uid UNIQUEIDENTIFIER,
--		@vids NVARCHAR(MAX),
--		@dios NVARCHAR(MAX)
		
--SET @vids = N'8F5BCD02-B01A-4B9C-BDDE-0C25F8FC0EF2'
--SET @uid = N'4469C9B3-5327-4D7F-BD10-6B15B3EFAFFA'
--SET @sdate = '2012-04-02 00:00'
--SET @edate = '2012-04-03 00:00'
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
	DigitalIoUri NVARCHAR(512)
)

DECLARE @tracedetails TABLE 
(
	VehicleId uniqueidentifier,
	VehicleIntId INT,
	IVhId uniqueidentifier,
	DriverId uniqueidentifier,
	DriverIntId INT,
	CreationCodeId smallint,
	SafeNameLong float,
	Lat float,
	Heading int,
	Speed int,
	TripDistance int,
	EventDateTime datetime,
	DigitalIO tinyint,
	SpeedLimit tinyint,
	LastOperation smalldatetime,
	Archived bit,
	CustomerId UNIQUEIDENTIFIER,
	EventId bigint,
	AttachedVehicleId uniqueidentifier,
	ReverseGeocode nvarchar(255),
	OdoDashboard FLOAT, 
	OdoGPS FLOAT, 
	OdoRoadSpeed FLOAT,
	AnalogData0 SMALLINT, 
	AnalogData1 SMALLINT, 
	AnalogData2 SMALLINT, 
	AnalogData3 SMALLINT, 
	AnalogData4 SMALLINT, 
	AnalogData5 SMALLINT
)

DECLARE @eventId BIGINT,
		@customerId UNIQUEIDENTIFIER,
		@vid UNIQUEIDENTIFIER,
		@eventTime DATETIME,
		@speedmult FLOAT,
		@distmult FLOAT,
		@timezone NVARCHAR(30),
		@status VARCHAR(255),
		@count INT
		
DECLARE @CustomerName NVARCHAR(MAX)
SELECT TOP 1 @CustomerName = c.Name 
FROM dbo.[User] u
	INNER JOIN dbo.Customer c ON u.CustomerID = c.CustomerId 
WHERE u.UserID = @uid AND u.Archived = 0 AND c.Archived = 0

IF @CustomerName = N'Hoyer'
BEGIN
	INSERT @results ( VehicleId, Registration, DigitalIoTypeId, DigitalIoTypeName , EventTime , EventId , CustomerId, DigitalIo , CreationCodeId , Lat , Lon , OnOff , TotalOn , TotalOff, StatusString, DigitalIoUri )
	EXECUTE [dbo].[proc_ReportDigitalIoVehicles_CFSeries] @vids, @uid, @sdate, @edate, @dios
END
ELSE BEGIN
	INSERT @results ( VehicleId, Registration, DigitalIoTypeId, DigitalIoTypeName , EventTime , EventId , CustomerId, DigitalIo , CreationCodeId , Lat , Lon , OnOff , TotalOn , TotalOff, StatusString, DigitalIoUri )
	EXECUTE [dbo].[proc_ReportDigitalIoVehicles] @vids, @uid, @sdate, @edate, @dios
END

DECLARE trace_cur CURSOR FAST_FORWARD FORWARD_ONLY FOR
	SELECT EventId, CustomerId, VehicleId, EventTime FROM @results

SET @timezone = [dbo].[UserPref](@uid, 600)
SET @speedmult = CAST([dbo].[UserPref](@uid,208) AS FLOAT)
SET @distmult = CAST([dbo].[UserPref](@uid,202) AS FLOAT)

OPEN trace_cur
FETCH NEXT FROM trace_cur INTO @eventId, @customerId, @vid, @eventTime
WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO @tracedetails
		SELECT TOP 1
			v.VehicleId,
			v.VehicleIntId,
			v.IVHId,
			d.DriverId,
			d.DriverIntId,
			e.CreationCodeId,
			e.Long as SafeNameLong,
			e.Lat,
			e.Heading,
			Cast(Round(e.Speed * @speedmult, 0) as smallint) as Speed,
			Cast(Round(e.OdoGPS * @distmult, 0) as int) as TripDistance,
			[dbo].[TZ_GetTime]( e.EventDateTime, @timezone, @uid) as EventDateTime,
			e.DigitalIO,
			e.SpeedLimit,
			e.LastOperation,
			e.Archived,
			c.CustomerId,
			e.EventId,
			NULL AS AttachedVehicleId,
			[dbo].[GetAddressFromLongLat] (e.Lat, e.Long) as ReverseGeoCode,
			e.OdoDashboard, e.OdoGPS, e.OdoRoadSpeed,
			e.AnalogData0, e.AnalogData1, e.AnalogData2, e.AnalogData3, e.AnalogData4, e.AnalogData5
		FROM dbo.[Event] e
			INNER JOIN dbo.Customer c ON e.CustomerIntId = c.CustomerIntId
			INNER JOIN dbo.[Vehicle] v ON e.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.Driver d ON e.DriverIntId = d.DriverIntId
		WHERE c.CustomerId = @customerId
			AND v.VehicleId = @vid
			AND e.EventId = @eventId
		ORDER BY v.VehicleId, e.EventDateTime DESC
	
	FETCH NEXT FROM trace_cur INTO @eventId, @customerId, @vid, @eventTime
END
CLOSE trace_cur
DEALLOCATE trace_cur

SELECT * FROM @results

SELECT * FROM @tracedetails

GO
