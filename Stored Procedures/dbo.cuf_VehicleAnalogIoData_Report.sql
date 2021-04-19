SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_VehicleAnalogIoData_Report]
(
	@vid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN
	--DECLARE	@vid UNIQUEIDENTIFIER,
	--		@sdate DATETIME,
	--		@edate DATETIME,
	--		@uid UNIQUEIDENTIFIER
	
	--SET @vid = N'B9C27C5D-4D96-49F9-AF23-2AB9BE740899'
	--SET @sdate = '2012-01-18 00:00'
	--SET @edate = '2012-01-18 23:59' 
	--SET @uid = N'C21039E7-58BE-4748-9A92-9AAB74AED58E'
	
	DECLARE @tempmult FLOAT,
			@liquidmult FLOAT
	SET @tempmult = ISNULL(dbo.[UserPref](@uid, 214),1)
	SET @liquidmult = ISNULL(dbo.[UserPref](@uid, 200),1)
		
	SET @sdate = dbo.TZ_ToUTC(@sdate,default,@uid)
	SET @edate = dbo.TZ_ToUTC(@edate,default,@uid)
	
	--SELECT * FROM dbo.Event ORDER BY EventDateTime DESC
	--SELECT * FROM dbo.Vehicle WHERE VehicleIntId = 23
	
	SELECT
		v.VehicleId,
		v.Registration,
		d.DriverId,
		dbo.FormatDriverNameByUser(d.DriverId, @uid) as DisplayName,
 		d.FirstName,
 		d.Surname,
 		d.MiddleNames,
 		d.Number,
 		d.NumberAlternate,
 		d.NumberAlternate2,
 		
 		dbo.[TZ_GetTime]( e.EventDateTime, default, @uid) AS EventDateTime,
 		e.Lat,
 		e.Long AS Lon,
 		e.Speed,
 		0 AS KeyOn,
 		NULL AS RawValue,
 		
 		dbo.GetScaleConvertAnalogValue(e.AnalogData0, 0, v.VehicleId, @tempmult, @liquidmult) AS Value1 , 
 		MIN(dbo.GetScaleConvertAnalogValue(e.AnalogData0, 0, v.VehicleId, @tempmult, @liquidmult)) AS MinTotal1 , 
 		MAX(dbo.GetScaleConvertAnalogValue(e.AnalogData0, 0, v.VehicleId, @tempmult, @liquidmult)) AS MaxTotal1 , 
 		AVG(dbo.GetScaleConvertAnalogValue(e.AnalogData0, 0, v.VehicleId, @tempmult, @liquidmult)) AS AverageTotal1 , 
 		'Sensor 1' AS LoomId1, 
 		
 		dbo.GetScaleConvertAnalogValue(e.AnalogData1, 1, v.VehicleId, @tempmult, @liquidmult) AS Value2 , 
 		MIN(dbo.GetScaleConvertAnalogValue(e.AnalogData1, 1, v.VehicleId, @tempmult, @liquidmult)) AS MinTotal2 , 
 		MAX(dbo.GetScaleConvertAnalogValue(e.AnalogData1, 1, v.VehicleId, @tempmult, @liquidmult)) AS MaxTotal2 , 
 		AVG(dbo.GetScaleConvertAnalogValue(e.AnalogData1, 1, v.VehicleId, @tempmult, @liquidmult)) AS AverageTotal2 , 
 		'Sensor 2' AS LoomId2, 
 		
 		dbo.GetScaleConvertAnalogValue(e.AnalogData2, 2, v.VehicleId, @tempmult, @liquidmult) AS Value3 , 
 		MIN(dbo.GetScaleConvertAnalogValue(e.AnalogData2, 2, v.VehicleId, @tempmult, @liquidmult)) AS MinTotal3 , 
 		MAX(dbo.GetScaleConvertAnalogValue(e.AnalogData2, 2, v.VehicleId, @tempmult, @liquidmult)) AS MaxTotal3 , 
 		AVG(dbo.GetScaleConvertAnalogValue(e.AnalogData2, 2, v.VehicleId, @tempmult, @liquidmult)) AS AverageTotal3 , 
 		'Sensor 3' AS LoomId3, 
 		
 		dbo.GetScaleConvertAnalogValue(e.AnalogData3, 3, v.VehicleId, @tempmult, @liquidmult) AS Value4 , 
 		MIN(dbo.GetScaleConvertAnalogValue(e.AnalogData3, 3, v.VehicleId, @tempmult, @liquidmult)) AS MinTotal4 , 
 		MAX(dbo.GetScaleConvertAnalogValue(e.AnalogData3, 3, v.VehicleId, @tempmult, @liquidmult)) AS MaxTotal4 , 
 		AVG(dbo.GetScaleConvertAnalogValue(e.AnalogData3, 3, v.VehicleId, @tempmult, @liquidmult)) AS AverageTotal4 , 
 		'Sensor 4' AS LoomId4, 
 		
 		NULL AS Value5 , NULL AS MinTotal5 , NULL AS MaxTotal5 , NULL AS AverageTotal5 , NULL AS LoomId5, 
		NULL AS Value6 , NULL AS MinTotal6 , NULL AS MaxTotal6 , NULL AS AverageTotal6 , NULL AS LoomId6, 
		NULL AS Value7 , NULL AS MinTotal7 , NULL AS MaxTotal7 , NULL AS AverageTotal7 , NULL AS LoomId7, 
		NULL AS Value8 , NULL AS MinTotal8 , NULL AS MaxTotal8 , NULL AS AverageTotal8 , NULL AS LoomId8, 
		NULL AS Value9 , NULL AS MinTotal9 , NULL AS MaxTotal9 , NULL AS AverageTotal9 , NULL AS LoomId9, 
		NULL AS Value10 , NULL AS MinTotal10 , NULL AS MaxTotal10 , NULL AS AverageTotal10 , NULL AS LoomId10
 	FROM dbo.Event e
 		INNER JOIN dbo.Driver d ON e.DriverIntId = d.DriverIntId
 		INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
 	WHERE 
 		e.EventDateTime BETWEEN @sdate AND @edate 
 		AND v.VehicleId = @vid
 	GROUP BY v.VehicleId, v.Registration, 
 	         d.DriverId, d.FirstName, d.Surname, d.MiddleNames, d.Number, d.NumberAlternate, d.NumberAlternate2,
			 e.EventDateTime, e.Lat, e.Long, e.Speed,
			 e.AnalogData0, e.AnalogData1, e.AnalogData2, e.AnalogData3
 	ORDER BY e.EventDateTime ASC
END


GO
