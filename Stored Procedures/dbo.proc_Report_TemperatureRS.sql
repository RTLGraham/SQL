SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_Report_TemperatureRS]
(
	@vehicleId uniqueidentifier,
	@sdate datetime,
	@edate datetime,
	@uid uniqueidentifier = null
)
AS

--TEST
--DECLARE   @vehicleId uniqueidentifier,
--          @sdate datetime,
--          @edate datetime,
--          @uid uniqueidentifier;

--SELECT    @vehicleId = N'EC6729BC-9BC9-42DB-95BB-3D5CCE659D50',
--          @sdate = '2012-06-28 00:00',
--          @edate = '2012-06-28 23:59',
--          @uid = N'DFA7CC7F-92FC-4BA6-9A32-F37BB3FDDE2F';

--SELECT    @vehicleId = N'BD5F9889-8007-4943-9001-46CB3ED2D36F',
--          @sdate = '2012-09-05 00:00',
--          @edate = '2012-09-06 23:59',
--          @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5';

--END

DECLARE   @vehicleIntId int,
          @Registration nvarchar(MAX),
          @timezone nvarchar(30),
          @tempmult FLOAT,
          @liquidmult FLOAT,
          @AnalogName1 nvarchar(MAX),
          @AnalogName2 nvarchar(MAX),
          @AnalogName3 nvarchar(MAX),
          @AnalogName4 nvarchar(MAX),
          @AnalogName5 nvarchar(MAX),
          @AnalogName6 nvarchar(MAX),
          @AlertName1 nvarchar(MAX),
          @AlertName2 nvarchar(MAX),
          @AlertName3 nvarchar(MAX),
          @AlertName4 nvarchar(MAX),
          @AlertColour1 nvarchar(MAX),
          @AlertColour2 nvarchar(MAX),
          @AlertColour3 nvarchar(MAX),
          @AlertColour4 nvarchar(MAX),
		  @Analog1Scaling FLOAT,
		  @Analog2Scaling FLOAT,
		  @Analog3Scaling FLOAT,
		  @Analog4Scaling FLOAT,
		  @Analog5Scaling FLOAT,
		  @Analog6Scaling FLOAT;

SELECT    @sdate = dbo.TZ_ToUTC(@sdate, default, @uid),
          @edate = dbo.TZ_ToUTC(@edate, default, @uid),
          @vehicleIntId = dbo.GetVehicleIntFromId(@vehicleId),
          @Registration = (SELECT Registration FROM dbo.Vehicle WHERE VehicleId = @vehicleId),
          @timezone = dbo.UserPref(@uid, 600),
          @tempmult = ISNULL(dbo.[UserPref](@uid, 214),1),
		  @liquidmult = ISNULL(dbo.[UserPref](@uid, 200),1);

SELECT    @AnalogName1 = (SELECT Description FROM dbo.VehicleSensor WHERE Enabled > 0 AND SensorId = 1 AND VehicleIntId = @vehicleIntId),
          @AnalogName2 = (SELECT Description FROM dbo.VehicleSensor WHERE Enabled > 0 AND SensorId = 2 AND VehicleIntId = @vehicleIntId),
          @AnalogName3 = (SELECT Description FROM dbo.VehicleSensor WHERE Enabled > 0 AND SensorId = 3 AND VehicleIntId = @vehicleIntId),
          @AnalogName4 = (SELECT Description FROM dbo.VehicleSensor WHERE Enabled > 0 AND SensorId = 4 AND VehicleIntId = @vehicleIntId),
          @AnalogName5 = (SELECT Description FROM dbo.VehicleSensor WHERE Enabled > 0 AND SensorId = 5 AND VehicleIntId = @vehicleIntId),
          @AnalogName6 = (SELECT Description FROM dbo.VehicleSensor WHERE Enabled > 0 AND SensorId = 6 AND VehicleIntId = @vehicleIntId),
          @AlertName1 = dbo.CFG_GetTemperatureAlertValueFromHistory(@vehicleId, 'Name_1', GETUTCDATE()),
          @AlertName2 = dbo.CFG_GetTemperatureAlertValueFromHistory(@vehicleId, 'Name_2', GETUTCDATE()),
          @AlertName3 = dbo.CFG_GetTemperatureAlertValueFromHistory(@vehicleId, 'Name_3', GETUTCDATE()),
          @AlertName4 = dbo.CFG_GetTemperatureAlertValueFromHistory(@vehicleId, 'Name_4', GETUTCDATE()),
          @AlertColour1 = dbo.CFG_GetTemperatureAlertValueFromHistory(@vehicleId, 'Colour_1', GETUTCDATE()),
          @AlertColour2 = dbo.CFG_GetTemperatureAlertValueFromHistory(@vehicleId, 'Colour_2', GETUTCDATE()),
          @AlertColour3 = dbo.CFG_GetTemperatureAlertValueFromHistory(@vehicleId, 'Colour_3', GETUTCDATE()),
          @AlertColour4 = dbo.CFG_GetTemperatureAlertValueFromHistory(@vehicleId, 'Colour_4', GETUTCDATE());
          
SELECT @Analog1Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vehicleintid AND SensorId = 1
SELECT @Analog2Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vehicleintid AND SensorId = 2
SELECT @Analog3Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vehicleintid AND SensorId = 3
SELECT @Analog4Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vehicleintid AND SensorId = 4
SELECT @Analog5Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vehicleintid AND SensorId = 5
SELECT @Analog6Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vehicleintid AND SensorId = 6

SELECT    @Registration AS Registration,
          '(' + D.Number + ') ' + COALESCE(D.Surname, '') + COALESCE(', ' + D.FirstName, '') AS Driver,
          COALESCE(VM.Name, VS.Description + CASE WHEN S.CreationCodeIdActive = CC.CreationCodeId
                                                  THEN CASE VCC.CreationCodeHighIsOff WHEN 1 
													THEN CASE WHEN @vehicleId != N'BE8FBF38-57CE-42E8-AC53-D67166463191' 
														THEN ' Geschlossen' 
														ELSE 'Load Area Closed'
													END
													ELSE CASE WHEN @vehicleId != N'BE8FBF38-57CE-42E8-AC53-D67166463191' 
														THEN ' Geöffnet' 
														ELSE 'Load Area Open'
													END 
												  END
                                                  ELSE CASE VCC.CreationCodeHighIsOff WHEN 1 
													THEN CASE WHEN @vehicleId != N'BE8FBF38-57CE-42E8-AC53-D67166463191' 
														THEN ' Geöffnet' 
														ELSE 'Load Area Open'
													END
													ELSE CASE WHEN @vehicleId != N'BE8FBF38-57CE-42E8-AC53-D67166463191' 
														THEN ' Geschlossen' 
														ELSE 'Load Area Closed'
													END 
												  END
                                                  END, CC.Name) AS Status,
          dbo.TZ_GetTime(E.EventDateTime, @timezone, @uid) AS EventDateTime,
          dbo.GetAddressFromLongLat(E.Lat, E.Long) AS ReverseGeoCode,
          CASE WHEN @AnalogName1 IS NULL THEN NULL ELSE CONVERT(decimal(18,2), dbo.ScaleConvertAnalogValue(E.AnalogData0, @Analog1Scaling, @tempmult, @liquidmult)) END AS AnalogValue1,
          CASE WHEN @AnalogName2 IS NULL THEN NULL ELSE CONVERT(decimal(18,2), dbo.ScaleConvertAnalogValue(E.AnalogData1, @Analog2Scaling, @tempmult, @liquidmult)) END AS AnalogValue2,
          CASE WHEN @AnalogName3 IS NULL THEN NULL ELSE CONVERT(decimal(18,2), dbo.ScaleConvertAnalogValue(E.AnalogData2, @Analog3Scaling, @tempmult, @liquidmult)) END AS AnalogValue3,
          CASE WHEN @AnalogName4 IS NULL THEN NULL ELSE CONVERT(decimal(18,2), dbo.ScaleConvertAnalogValue(E.AnalogData3, @Analog4Scaling, @tempmult, @liquidmult)) END AS AnalogValue4,
          COALESCE(@AnalogName1, 'N/A') AS AnalogName1,
          COALESCE(@AnalogName2, 'N/A') AS AnalogName2,
          COALESCE(@AnalogName3, 'N/A') AS AnalogName3,
          COALESCE(@AnalogName4, 'N/A') AS AnalogName4,
          @AnalogName1 + ': ' + CONVERT(nvarchar(MAX), CONVERT(decimal(18,2), dbo.ScaleConvertAnalogValue(E.AnalogData0, @Analog1Scaling, @tempmult, @liquidmult))) AS Analog1,
          @AnalogName2 + ': ' + CONVERT(nvarchar(MAX), CONVERT(decimal(18,2), dbo.ScaleConvertAnalogValue(E.AnalogData1, @Analog2Scaling, @tempmult, @liquidmult))) AS Analog2,
          @AnalogName3 + ': ' + CONVERT(nvarchar(MAX), CONVERT(decimal(18,2), dbo.ScaleConvertAnalogValue(E.AnalogData2, @Analog3Scaling, @tempmult, @liquidmult))) AS Analog3,
          @AnalogName4 + ': ' + CONVERT(nvarchar(MAX), CONVERT(decimal(18,2), dbo.ScaleConvertAnalogValue(E.AnalogData3, @Analog4Scaling, @tempmult, @liquidmult))) AS Analog4,
          @AnalogName5 + ': ' + CONVERT(nvarchar(MAX), CONVERT(decimal(18,2), dbo.ScaleConvertAnalogValue(E.AnalogData4, @Analog5Scaling, @tempmult, @liquidmult))) AS Analog5,
          @AnalogName6 + ': ' + CONVERT(nvarchar(MAX), CONVERT(decimal(18,2), dbo.ScaleConvertAnalogValue(E.AnalogData5, @Analog6Scaling, @tempmult, @liquidmult))) AS Analog6,
          CASE WHEN dbo.TestBits(E.AnalogData5, 1) > 0 THEN COALESCE(@AlertName1, 'Alert 1') ELSE NULL END AS Alert1,
          CASE WHEN dbo.TestBits(E.AnalogData5, 2) > 0 THEN COALESCE(@AlertName1, 'Alert 2') ELSE NULL END AS Alert2,
          CASE WHEN dbo.TestBits(E.AnalogData5, 4) > 0 THEN COALESCE(@AlertName1, 'Alert 3') ELSE NULL END AS Alert3,
          CASE WHEN dbo.TestBits(E.AnalogData5, 8) > 0 THEN COALESCE(@AlertName1, 'Alert 4') ELSE NULL END AS Alert4
          --@AlertColour1 AS AnalogAlert1Colour,
          --@AlertColour2 AS AnalogAlert2Colour,
          --@AlertColour3 AS AnalogAlert3Colour,
          --@AlertColour4 AS AnalogAlert4Colour
FROM      dbo.Event E
          LEFT OUTER JOIN dbo.Driver D ON D.DriverIntId = E.DriverIntId
          --For statuses
          LEFT OUTER JOIN dbo.CreationCode CC ON CC.CreationCodeId = E.CreationCodeId
          --Digital Inputs
          LEFT OUTER JOIN dbo.Sensor S ON S.CreationCodeIdActive = CC.CreationCodeId OR S.CreationCodeIdInactive = CC.CreationCodeId
          LEFT OUTER JOIN dbo.VehicleSensor VS ON VS.SensorId = S.SensorId AND VS.VehicleIntId = E.VehicleIntId
          LEFT OUTER JOIN dbo.VehicleCreationCode VCC ON VCC.CreationCodeId = CC.CreationCodeId AND VCC.VehicleId = @vehicleId
          --Vehicle Mode
          LEFT OUTER JOIN dbo.VehicleModeCreationCode VMCC ON VMCC.CreationCodeId = CC.CreationCodeId
          LEFT OUTER JOIN VehicleMode VM ON VM.VehicleModeId = VMCC.VehicleModeId AND VM.VehicleModeId != 0
WHERE     E.EventDateTime BETWEEN @sdate AND @edate
AND       E.VehicleIntId = @vehicleIntId
AND       E.CreationCodeId IN (1,2,3,4,5,6,7,8,9,10,12,13,14,15,16,17,18,19,29,61,100,42,43,123)
-- CC 123 added for warehouse units
AND       E.Lat != 0
AND       E.Long != 0
ORDER BY  E.VehicleintId, E.EventDateTime ASC;
GO
