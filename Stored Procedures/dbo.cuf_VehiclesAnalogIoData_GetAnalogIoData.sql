SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_VehiclesAnalogIoData_GetAnalogIoData]
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

--SET @vid = N'B205A51A-DD46-435E-A979-28B567A895A6'
--SET @sdate = '2010-12-12'
--SET @edate = '2010-12-14'
--SET @uid = (SELECT TOP 1 UserId FROM [D_RTL2Application].dbo.[User] WHERE name ='dima' AND Password = 'dima' AND Archived = 0)

DECLARE @timezone VARCHAR(255)
SET @timezone = dbo.UserPref(@uid, 600)

DECLARE @results TABLE
(
	VehicleId UNIQUEIDENTIFIER,
	Registration VARCHAR(50),
	DriverId UNIQUEIDENTIFIER,
	DriverName VARCHAR(255),
	EventDateTime DATETIME,
	Lat FLOAT,
	Lon FLOAT,
	Speed FLOAT,
	KeyOn BIT,
	RawValue VARCHAR(MAX),
	
	Value1 FLOAT,
	MinTotal1 FLOAT,
	MaxTotal1 FLOAT,
	AverageTotal1 FLOAT,
	LoomId1 NVARCHAR(255),
	
	Value2 FLOAT,
	MinTotal2 FLOAT,
	MaxTotal2 FLOAT,
	AverageTotal2 FLOAT,
	LoomId2 NVARCHAR(255),
	
	Value3 FLOAT,
	MinTotal3 FLOAT,
	MaxTotal3 FLOAT,
	AverageTotal3 FLOAT,
	LoomId3 NVARCHAR(255),
	
	Value4 FLOAT,
	MinTotal4 FLOAT,
	MaxTotal4 FLOAT,
	AverageTotal4 FLOAT,
	LoomId4 NVARCHAR(255),
	
	Value5 FLOAT,
	MinTotal5 FLOAT,
	MaxTotal5 FLOAT,
	AverageTotal5 FLOAT,
	LoomId5 NVARCHAR(255),
	
	Value6 FLOAT,
	MinTotal6 FLOAT,
	MaxTotal6 FLOAT,
	AverageTotal6 FLOAT,
	LoomId6 NVARCHAR(255),

	Value7 FLOAT,
	MinTotal7 FLOAT,
	MaxTotal7 FLOAT,
	AverageTotal7 FLOAT,
	LoomId7 NVARCHAR(255),

	Value8 FLOAT,
	MinTotal8 FLOAT,
	MaxTotal8 FLOAT,
	AverageTotal8 FLOAT,
	LoomId8 NVARCHAR(255),

	Value9 FLOAT,
	MinTotal9 FLOAT,
	MaxTotal9 FLOAT,
	AverageTotal9 FLOAT,
	LoomId9 NVARCHAR(255),

	Value10 FLOAT,
	MinTotal10 FLOAT,
	MaxTotal10 FLOAT,
	AverageTotal10 FLOAT,
	LoomId10 NVARCHAR(255)
)

INSERT INTO @results (VehicleId, Registration, DriverId, DriverName, EventDateTime, Lat, Lon, Speed, KeyOn, RawValue )
SELECT	v.VehicleId,
		v.Registration,
		d.DriverId,
		(d.Surname + ', ' + d.FirstName) AS DriverName,
		dbo.TZ_GetTime(iod.EventDateTime, @timezone, @uid) AS EventDateTime,
		iod.Lat,
		iod.Long AS Lon,
		iod.Speed, 
		iod.KeyOn,
		iod.Value
FROM dbo.VehicleAnalogIoData iod
INNER JOIN dbo.Vehicle v ON iod.VehicleIntId = v.VehicleIntId
LEFT OUTER JOIN dbo.Driver d ON iod.DriverIntId = d.DriverIntId
WHERE v.VehicleId = @vid
AND iod.EventDateTime BETWEEN @sdate AND @edate
GROUP BY v.VehicleId, v.Registration, d.DriverId, (d.Surname + ', ' + d.FirstName), iod.EventDateTime,
		 iod.Lat, iod.Long, iod.Speed, iod.KeyOn, iod.Value

SELECT *
FROM @results
ORDER BY EventDateTime

GO
