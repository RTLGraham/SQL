SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [dbo].[proc_ReportMaintenance]    Script Date: 09/21/2011 12:14:55 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

CREATE PROCEDURE [dbo].[proc_ReportMaintenanceHealthCheck_RS]
    (
      @vids varchar(max),
      @uid UNIQUEIDENTIFIER
    )
AS 
    SET NOCOUNT ON
	
--	DECLARE @vids varchar(max),
--			@uid uniqueidentifier
--
--	SET @vids = N'FB0C91E1-401B-427B-B3EE-7AC8A4294BF3,9A615ECD-2389-4D20-B0BE-8667626A38BA,6913DDBF-6FAC-4E5B-A33D-0D61CA692791,C8268ABE-8E32-4C44-B7CB-C567C61F8897,2682E712-C15D-4C12-9C84-84601446E3F6,250F5527-CF24-427E-A514-F52F42E7B51A,47926EE9-A90E-401B-8673-D16D8330D2B7,909FB8A2-A973-4253-99C1-03EAF670C13B,9F754430-BDF3-4F5A-9454-092C21FE247A,5F3CEA35-DCBE-4120-9301-09FF638BF9DF,ABAC69E6-CCCC-4E60-9F81-0B14A2CE8CFD,7A03DFD2-3982-46E8-8C4E-12F297DEE350,8016F50D-A2D1-49A9-BC1E-13AE27953390,FE456C02-2AC4-4813-9473-13F82137005A,53B878DA-091D-4722-B467-1463EE502C19,AD7AE29D-1328-4228-B4C2-194D6C90A266,2F29E214-4249-4412-9927-1BBFF111DF1B,46D70EB7-624A-4F2D-92D7-1DB630EE116F,9264E0AD-E96D-4974-B0FD-1E50DDF18BDD,5AAB0E74-D39E-483B-AAFF-200FB5A56850,1860348D-20B5-42CF-BA66-203864BA0461,2FE4DD9B-905F-477A-A710-218A4E5C6750,EF8191E1-ABED-480F-99C3-243BC4E7EEE7,04D11745-A145-4215-A432-2A5061B9DC17,AF6A1AEC-0BF5-4224-8A04-2BF2659C2739,3636AE89-04DF-4AE1-95AB-2C06253041BA,16DF929B-A773-46D2-900E-2CA8DCF23893,87A3B70E-9B8D-42CB-BB13-2E1C9427331C,2C38D238-E1A6-4E08-B419-345ACB40930F,93431E81-EE44-4EEE-A959-387B6E4F9CE3,D1742CC9-A5E3-434E-A9E8-3A1D858B1DE4,FA6E62CA-3470-4F73-A32D-3C79BF6206A9,A1AE4401-9643-4A36-94C7-3E93BE0646C4,9DFE074E-F8B7-44C0-8BAA-3FB046ED29A2,5146C0B8-5CE5-44E1-A6C6-41D2E201EF76,BD5F9889-8007-4943-9001-46CB3ED2D36F,39512BD9-7CCF-48AD-9623-46CD000D2AC6,B639621D-7C4D-4B91-8DDF-486051D96448,49482BB6-B7CC-40C1-9F61-48728BF61A8E,4DA5FA6D-8496-4D75-AA6A-4C32B377BDF9,2E7984F5-D541-4070-969B-4DEFA0130CB5,9BBD17D4-3BE2-4E29-B550-509AB56CA92F,BF48CB72-BEC8-475E-A8E3-511D485F15BF,486A43F1-70D9-46CC-A745-542B6A4D77CE,AC4A7F16-ACAF-41E5-B7CB-57C1C3123C20,339C8146-9790-4CFE-B974-5819ECC299C0,5DE385BF-BFCB-4179-90CB-5AEE460B14AD,C5868274-5850-4762-8EA8-5B5B7C1C2B5B,F30F1966-C7B8-4980-BFFE-5B930071D32D,C83D509F-26C0-4ED6-9D12-5C5D9716789D,67B44E7F-6A0E-42E0-9DCF-5DDCA2AF502E,2C1A82DE-6DCB-4D03-BC21-5F65198B9A84,991F0624-E911-4A0A-9E34-632B912A9C38,BD15D85F-F591-4AB5-881A-65E296715D18,24D1F780-C878-4FF0-A6D8-68B5FDA92CBB,33A67A70-9935-4214-B7B0-69B7AC228F5C,DB3AC174-1CFE-404C-914B-6BE9DB1B7038,8780C077-1BCB-4EF9-AC7A-6D763D0B5721,AB2E895D-CB6F-4BD9-8CF1-71E976E6F335,C7343CE2-50EF-4AA2-AAAC-736442ECFA0A,14337BBF-9F3F-4624-9B84-73CB3485BDEE,202B4D58-3993-43D1-A8C5-7BC46C7CEFA5,EB5F8AE0-FC95-4D38-87FE-801C22911CA6,A2A7640A-7CD1-48D3-8270-80A8F2C9FA63,2D68CB77-FE15-4030-839A-824B6D0806BA,6F6C50EC-608F-4528-A69C-838BDBECAAF5,2F060A96-D3F8-4363-88D1-86D6F605976E,CF6E7729-C9E7-4373-BEAB-895D9A2F1379,8288801A-186F-4BE4-A044-8A4007BD2372,77A0110C-5D6C-493A-9C16-8A59A9ABD5B4,0BBEF81F-92A9-4183-A354-8B15F4B354DD,747C1E8B-7F86-4BB3-9AC3-8C4E319272B2,6CD1331B-F7FC-4866-A333-8FEE45667F33,7DE5AA38-2BA3-4C8F-A488-911911DA6F80,6659A865-3221-4DC1-8682-92B1AEA9251E,5C77C772-4FCA-4040-BDF7-942B2E153FFF,68CF88EA-D828-4D33-A849-9441A63D5E8D,B88446F6-CDEE-456D-9896-9743AEDD4D9A,1D3D521A-9CFF-4B73-BC2E-97ADB314A3A2,061C8BAA-F34C-468E-BB72-9C4162664851,284944F1-4BB4-4ED7-B49D-9E318203E950,767A5BB3-0077-4799-AC91-9E88279E99F1,8C2E8B0E-E258-4F27-8BE6-9EE90EF08614,D92E730A-EAA8-4675-A625-9F9F7E6E7B16,DB306411-629E-445B-8FE9-9FE65C285296,DFB2454E-1286-473B-9215-A38D8717CE57,AE9AD52F-7659-4339-BB56-A39AC3923A54,4DD73B7F-2FC4-4F06-B888-A4C4AA923C58,42C9DA5C-2BF6-4A23-865A-A5AB067F8DFA,3FF3032B-D9DC-4FE8-834B-A6EB6FC3C7CB,4723BA01-21CE-4FFB-85E7-A754BF858BC7,B8C522B8-99C0-4630-A4DE-A7A523437829,3708F23A-F7CA-44F0-BB96-A94E80C40DFF,DF0D3E78-19EB-4779-BAE8-A974FE4F1B33,7F0079D1-5D4E-47D8-AFEA-A9835C3A3D00,F16007E6-0BED-44B4-8725-AE703F1F2285,74EEE16C-CF22-4DE3-B677-B5BBC86BBDC4,D622FBC6-9804-4298-B7D8-B83A04A1E620,3D0FA257-E0E9-4009-9508-BBFFA244F817,D5C0A3B0-0996-4D3C-B7F5-BC360B98B024,F5F18987-540E-44A0-A9EB-BC42699EFA30,2E7A5E82-702A-4003-BB17-C072A93ED941,18750389-36C6-4D3E-BE79-C54B859CE83B,2C63EBDD-07D4-4F26-A3A4-C5E18DBCB5CF,6CC1F03D-9CCB-47CB-8796-C641A5B951C3,BF808915-A86D-4EB8-9804-C64375223662,223B3FF2-E259-4460-B4BD-C6979B626432,EF7D5DF1-3744-4233-ADAE-C6A24B16B87B,B52C20AA-96D0-4249-8EC1-C7751A385D87,0A293ED6-5DE5-4B92-BDF0-C8357DF9003D,383FC529-05E2-4F17-ABD5-C9E08895E29D,09504D20-457C-49EC-A6EE-CC7DAA4C4252,D103A123-A2A2-4EF1-97DF-D184E971FE7B,D9FFD177-BC18-4348-A771-D18F39522D6B,49D600B5-E440-4A61-BF2F-D2C78BA278E6,C98B01D1-B2E7-4378-A1A4-D5245CDDDF0D,3AAEA81D-20C4-4F24-B022-DECA9C7C51B1,28E3452A-A515-45BC-B95F-DED8A0EB1CD8,79626E6C-F770-4223-A2F8-DFDD491578EF,88EADF4C-8B3E-488D-A755-E05AB60B3AE0,5081472D-203E-4F21-9CF8-E1F98619361A,97E3C42B-0940-404F-B0FE-E4AD4981E728,76EE70C2-598A-4C1F-85C0-E5A102CD70F2,53D2962E-9E72-466E-B703-E5BA47474BAD,EA9340A7-EA1D-43F1-A213-E95B7BE2225E,B7EEE367-B07C-4441-86EF-EB7E5613F7EF,87B51B30-B441-4A79-AD36-ED2BAD3E3204,7B27F3D7-3BAC-40AC-9B30-ED9211329331,9208ED3D-1CD6-41B1-B8F4-EDC4F5141869,074D27DA-97B6-42FC-920E-EEF395553804,37415C60-7E05-4F91-8A32-F26DF518CF80,5632AB2C-95E1-4D21-BA04-F6104F5238CC,3554137E-4695-46AC-A678-F6428E995B91,A2609578-A02A-4150-8525-F86F3E0C2177,D075F7EF-C02E-46E4-91C3-8191F2167F59,577536E5-4AED-4450-A8DF-F5F6AC54A3FD,3C9147A8-999D-41F0-9175-786993086FE4,9B2B5A35-D0D9-4776-BB1F-87B27DBFD2CC,A158F8A8-D73B-4EEF-962B-670C1BAB6696,0FADC446-F107-4EF5-B23A-93CF7EA917E7,901BCFF8-BE83-4C2C-90E2-A7E0C80A1D99,02F1446D-BB14-4B9F-9D72-8C13BBFDF9D7'
----	SET @vids = N'18750389-36C6-4D3E-BE79-C54B859CE83B'
--	SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
    
    DECLARE @diststr varchar(20),
        @distmult float,
        @fuelstr varchar(20),
        @fuelmult float,
        @co2str varchar(20),
        @co2mult FLOAT,
        @liquidstr varchar(20),
        @liquidmult FLOAT,
        @days INT

	SET @days = -7
    SELECT  @diststr = [dbo].UserPref(@uid, 203)
    SELECT  @distmult = [dbo].UserPref(@uid, 202)
    SELECT  @fuelstr = [dbo].UserPref(@uid, 205)
    SELECT  @fuelmult = [dbo].UserPref(@uid, 204)
    SELECT  @co2str = [dbo].UserPref(@uid, 211)
    SELECT  @co2mult = [dbo].UserPref(@uid, 210)
    SELECT  @liquidstr = [dbo].UserPref(@uid, 201)
    SELECT  @liquidmult = [dbo].UserPref(@uid, 200)

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
          DistanceUnit NVARCHAR(MAX),
          FuelUnit NVARCHAR(MAX),
          LiquidUnit NVARCHAR(MAX),
          Co2Unit NVARCHAR(MAX),
          
          Ignition INT,
          
          OdoGPS FLOAT,
          OdoCAN FLOAT,
          
          DriverIdCount INT,
          
          IdDistance FLOAT,
          NoIdDistance FLOAT,
          NoIdLatestTime DATETIME,
          
          DrivingFuel FLOAT,
          AverageEngineRPM FLOAT,
          
          iButton INT,
          Tacho INT,
          
          CheetahFaults INT,
          SS1Faults INT,
          
          Sensor01 NVARCHAR(MAX),
          Sensor02 NVARCHAR(MAX),
          Sensor03 NVARCHAR(MAX),
          Sensor04 NVARCHAR(MAX),
          
          Sensor01Faults INT,
          Sensor02Faults INT,
          Sensor03Faults INT,
          Sensor04Faults INT
        )
      
	INSERT INTO @results (VehicleId, Registration, VehicleTypeID, DaysNotPolled, LastPoll, PollLat, PollLon, PollLocation, EventDateTime, FirmwareVersion,  
						DistanceUnit, FuelUnit, LiquidUnit, Co2Unit, Ignition, OdoGPS, OdoCAN, DriverIdCount, IdDistance, NoIdDistance, NoIdLatestTime, 
						DrivingFuel, AverageEngineRPM, iButton, Tacho, 
						CheetahFaults, SS1Faults, Sensor01, Sensor02, Sensor03, Sensor04, Sensor01Faults, Sensor02Faults, Sensor03Faults, Sensor04Faults)    
	SELECT      v.VehicleId,
				v.Registration,
				v.VehicleTypeID,
				DATEDIFF(day, e.EventDateTime, GETUTCDATE()) AS DaysNotPolled,
				dbo.TZ_GetTime(e.EventDateTime, DEFAULT, @uid) AS LastPoll,
				e.Lat AS PollLat,
				e.Long AS PollLon,
				dbo.GetGeofenceNameFromLongLat (e.Lat, e.Long, @uid, dbo.GetAddressFromLongLat(e.Lat, e.Long)) as PollLocation,
				e.EventDateTime,
				i.FirmwareVersion,
				@diststr AS DistanceUnit,
				@fuelstr AS FuelUnit,
				@liquidstr AS LiquidUnit,
				@co2str AS Co2Unit,
				
				(SELECT COUNT(*)
				 FROM dbo.Event evt
				 WHERE evt.VehicleIntId = v.VehicleIntId		
					AND evt.EventDateTime BETWEEN DATEADD(DAY, @days, e.EventDateTime) AND e.EventDateTime
					AND CreationCodeId in (4,5)) AS Ignition,
				
				oTmp.OdoGPS AS OdoGPS,
				rpt.CANDistance,
				dTmp.DriverIdCount AS DriverIdCount,

				rId.IdDistance,
				rNoId.NoIdDistance,				
				rNoId.NoIdLatestTime,				
				rpt.DrivingFuel,
					
				NULL AS AverageEngineRPM,
				
				(SELECT COUNT(edIB.EventDataName) 
				 FROM dbo.EventData edIB
				 WHERE edIB.VehicleIntId = e.VehicleIntId
					AND edIB.EventDataName = 'SRC' 
					AND edIB.EventDataString = 'IB'
					AND edIB.LastOperation BETWEEN DATEADD(DAY, @days, e.EventDateTime) AND e.EventDateTime
				) AS iButton,
				(SELECT COUNT(edT.EventDataName) 
				 FROM dbo.EventData edT	
				 WHERE edT.VehicleIntId = e.VehicleIntId
					AND edT.EventDataName = 'SRC' 
					AND edT.EventDataString IN ('VD','ST')			
					AND edT.LastOperation BETWEEN DATEADD(DAY, @days, e.EventDateTime) AND e.EventDateTime
				) AS Tacho,
				
				(SELECT COUNT(edT.EventDataName) 
				 FROM dbo.EventData edT	
				 WHERE edT.VehicleIntId = e.VehicleIntId
					AND edT.EventDataName = 'ERR' 			
					AND edT.LastOperation BETWEEN DATEADD(DAY, @days, e.EventDateTime) AND e.EventDateTime
				) AS CheetahFaults,
				(SELECT COUNT(edT.EventDataName) 
				 FROM dbo.EventData edT	
				 WHERE edT.VehicleIntId = e.VehicleIntId
					AND edT.EventDataName = 'SS1' 			
					AND edT.LastOperation BETWEEN DATEADD(DAY, @days, e.EventDateTime) AND e.EventDateTime
				) AS SS1Faults,
				
				ss.Sensor01,
				ss.Sensor02,
				ss.Sensor03,
				ss.Sensor04,
				
				ss.Sensor01Faults,
				ss.Sensor02Faults,
				ss.Sensor03Faults,
				ss.Sensor04Faults
	FROM		dbo.Vehicle v
				INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
				INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
				INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
				INNER JOIN (	SELECT evt.VehicleIntId, evt.CustomerIntId, MAX(evt.EventId) AS EventId
								FROM dbo.Event evt
									INNER JOIN dbo.Vehicle vv ON evt.VehicleIntId = vv.VehicleIntId
								WHERE vv.VehicleId IN ( SELECT Value FROM dbo.Split(@vids, ','))
								  AND evt.EventDateTime BETWEEN (SELECT TOP 1 vle.EventDateTime 
																 FROM dbo.VehicleLatestEvent vle
																 WHERE vle.VehicleId = vv.VehicleId) AND GETUTCDATE()
								GROUP BY evt.VehicleIntId, evt.CustomerIntId) ev ON
																	 ev.VehicleIntId = v.VehicleIntId
																	 AND ev.CustomerIntId = c.CustomerIntId
				INNER JOIN dbo.Event e ON ev.EventId = e.EventId			
				LEFT OUTER JOIN
					(
						SELECT v.VehicleId, CAST((MAX(evt.OdoGPS) - MIN(evt.OdoGPS)) AS FLOAT) * @distmult AS OdoGPS
						FROM dbo.Event evt
							INNER JOIN dbo.Vehicle v ON evt.VehicleIntId = v.VehicleIntId
							INNER JOIN dbo.VehicleLatestEvent vle ON v.VehicleId = vle.VehicleId
						WHERE v.VehicleId IN ( SELECT Value FROM dbo.Split(@vids, ','))
							AND evt.EventDateTime BETWEEN CAST(FLOOR(CAST(DATEADD(DAY, @days, vle.EventDateTime) AS FLOAT)) + 1 AS DATETIME) AND vle.EventDateTime
							AND evt.OdoGPS != 0
						GROUP BY v.VehicleId
					 ) AS oTmp ON oTmp.VehicleId = v.VehicleId	
					
				--   /*BAD PERFORMANCE*/
				LEFT OUTER JOIN 
					(
						SELECT v.VehicleId, COUNT(*) AS DriverIdCount
						FROM dbo.Event evt
							INNER JOIN dbo.Driver drvr ON evt.DriverIntId = drvr.DriverIntId
							INNER JOIN dbo.Vehicle v ON evt.VehicleIntId = v.VehicleIntId
							INNER JOIN dbo.VehicleLatestEvent vle ON v.VehicleId = vle.VehicleId
						WHERE v.VehicleId IN ( SELECT Value FROM dbo.Split(@vids, ','))
							AND evt.EventDateTime BETWEEN DATEADD(DAY, @days, vle.EventDateTime) AND vle.EventDateTime
							AND evt.CreationCodeId = 61 AND drvr.Number != 'No ID' AND drvr.Number NOT LIKE '%fff%00%fff%'
						GROUP BY v.VehicleId
					) AS dTmp ON v.VehicleId = dTmp.VehicleId
				LEFT OUTER JOIN 
					(
						SELECT	v.VehicleId,
								CASE WHEN AVG(e.AnalogData0) != 192 THEN 'Active' ELSE 'Inactive' END AS Sensor01,
								CASE WHEN AVG(e.AnalogData1) != 192 THEN 'Active' ELSE 'Inactive' END AS Sensor02,
								CASE WHEN AVG(e.AnalogData2) != 192 THEN 'Active' ELSE 'Inactive' END AS Sensor03,
								CASE WHEN AVG(e.AnalogData3) != 192 THEN 'Active' ELSE 'Inactive' END AS Sensor04,
								
								CASE WHEN MAX(CAST(e.AnalogData0 AS INT)) - MIN(CAST(e.AnalogData0 AS INT)) > 0 THEN 0 ELSE 1 END AS Sensor01Faults,
								CASE WHEN MAX(CAST(e.AnalogData1 AS INT)) - MIN(CAST(e.AnalogData1 AS INT)) > 0 THEN 0 ELSE 1 END AS Sensor02Faults,
								CASE WHEN MAX(CAST(e.AnalogData2 AS INT)) - MIN(CAST(e.AnalogData2 AS INT)) > 0 THEN 0 ELSE 1 END AS Sensor03Faults,
								CASE WHEN MAX(CAST(e.AnalogData3 AS INT)) - MIN(CAST(e.AnalogData3 AS INT)) > 0 THEN 0 ELSE 1 END AS Sensor04Faults
						FROM dbo.Event e
							INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
							INNER JOIN dbo.VehicleLatestEvent vle ON v.VehicleId = vle.VehicleId
						WHERE v.VehicleId IN ( SELECT Value FROM dbo.Split(@vids, ',')) 
							AND e.EventDateTime BETWEEN DATEADD(DAY, -1, vle.EventDateTime) AND vle.EventDateTime
						GROUP BY v.VehicleId
					) ss ON ss.VehicleId = v.VehicleId
					
				INNER JOIN 
					(
						SELECT v.VehicleId, 
						SUM(r.DrivingDistance) * 1000 * @distmult AS CANDistance,
						SUM(r.DrivingFuel) AS DrivingFuel
						FROM dbo.Reporting r
							INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
							INNER JOIN dbo.VehicleLatestEvent vle ON v.VehicleId = vle.VehicleId
						WHERE v.VehicleId IN ( SELECT Value FROM dbo.Split(@vids, ',')) 
							AND r.Date BETWEEN DATEADD(DAY, @days, vle.EventDateTime) AND vle.EventDateTime
						GROUP BY v.VehicleId
					) rpt ON rpt.VehicleId = v.VehicleId
					
				INNER JOIN 
					(
						SELECT v.VehicleId, 
						SUM(r.DrivingDistance) * 1000 * @distmult AS NoIdDistance,
						dbo.TZ_GetTime(MAX(r.Date), DEFAULT, @uid) AS NoIdLatestTime
						FROM dbo.Reporting r
							INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
							INNER JOIN dbo.VehicleLatestEvent vle ON v.VehicleId = vle.VehicleId
						WHERE v.VehicleId IN ( SELECT Value FROM dbo.Split(@vids, ',')) 
							AND r.DriverIntId IN (SELECT DriverIntId FROM dbo.Driver dNoId WHERE dNoId.Number = 'No ID')
							AND r.Date BETWEEN DATEADD(DAY, @days, vle.EventDateTime) AND vle.EventDateTime
						GROUP BY v.VehicleId
					) rNoId ON rNoId.VehicleId = v.VehicleId					

				INNER JOIN 
					(
						SELECT v.VehicleId, 
						SUM(r.DrivingDistance) * 1000 * @distmult AS IdDistance
						FROM dbo.Reporting r
							INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
							INNER JOIN dbo.VehicleLatestEvent vle ON v.VehicleId = vle.VehicleId
						WHERE v.VehicleId IN ( SELECT Value FROM dbo.Split(@vids, ','))
							AND r.DriverIntId NOT IN (SELECT DriverIntId FROM dbo.Driver dNoId WHERE dNoId.Number = 'No ID') 
							AND r.Date BETWEEN DATEADD(DAY, @days, vle.EventDateTime) AND vle.EventDateTime
						GROUP BY v.VehicleId
					) rId ON rId.VehicleId = v.VehicleId	
					
	WHERE		v.VehicleId IN ( SELECT Value FROM dbo.Split(@vids, ',') )
					AND cv.Archived = 0 AND cv.EndDate IS NULL
	GROUP BY	v.VehicleId, v.Registration, v.VehicleTypeID, e.EventDateTime, e.Lat, e.Long, e.EventDateTime, i.FirmwareVersion, v.VehicleIntId, e.VehicleIntId
				,ss.Sensor01, ss.Sensor01Faults
				,ss.Sensor02, ss.Sensor02Faults
				,ss.Sensor03, ss.Sensor03Faults
				,ss.Sensor04, ss.Sensor04Faults
				,oTmp.OdoGPS, rpt.CANDistance, rpt.DrivingFuel,
				rId.IdDistance, rNoId.NoIdDistance, rNoId.NoIdLatestTime,
				dTmp.DriverIdCount
    
    SELECT VehicleId,
          Registration,
          VehicleTypeID,
          DaysNotPolled,
          LastPoll,
          PollLat,
          PollLon,
          PollLocation,
          ISNULL(FirmwareVersion, '') AS FirmwareVersion,
          
          CASE WHEN Ignition > 0 THEN 1 ELSE 0 END AS Ignition,
          
          dbo.ZeroYieldNull(OdoGPS) AS OdoGPS, 
          
          dbo.ZeroYieldNull(OdoCAN) AS OdoCAN,  
          
          CASE WHEN ISNULL(OdoCAN,0) = 0 
			THEN NULL 
			ELSE CASE WHEN (OdoGPS / (CASE WHEN OdoCAN = 0 THEN NULL ELSE OdoCAN END) BETWEEN 0.9 AND 1.1) 
						THEN 1 
						ELSE 0 
						END 
			END AS OdoCANCheck,
          
          ISNULL(DriverIdCount, 0) AS DriverIdCount,
                 
          dbo.ZeroYieldNull(IdDistance) AS IdDistance,
          CASE WHEN dbo.ZeroYieldNull(NoIdDistance) < 10 THEN NULL ELSE dbo.ZeroYieldNull(NoIdDistance) END AS NoIdDistance,
		  CASE WHEN dbo.ZeroYieldNull(NoIdDistance) IS NULL OR dbo.ZeroYieldNull(NoIdDistance) < 10 THEN NULL ELSE NoIdLatestTime END AS NoIdLatestTime,
		  
		  ISNULL(DrivingFuel, 0) as DrivingFuel, 
		  dbo.ZeroYieldNull(AverageEngineRPM) as AverageEngineRPM, 
		  		  						
		  CASE WHEN iButton > 0 THEN 1 ELSE 0 END AS iButton,
		  CASE WHEN Tacho > 0 THEN 1 ELSE 0 END AS Tacho,
          
          CheetahFaults,
          SS1Faults,
          
          Sensor01,
		  Sensor01Faults,
		  Sensor02,
		  Sensor02Faults,
		  Sensor03,
		  Sensor03Faults,
		  Sensor04,
		  Sensor04Faults,
          
          DistanceUnit,
          FuelUnit,
          LiquidUnit,
          Co2Unit,
          CASE WHEN COUNT(co.CheckOutReason) > 0 THEN 1 ELSE 0 END AS IsCheckedOut,
          co.CheckoutReason
    FROM @results r
		LEFT OUTER JOIN dbo.TAN_EntityCheckOut co ON co.EntityId = r.VehicleId
																	AND GETUTCDATE() BETWEEN co.CheckOutDateTime AND co.CheckInDateTime
    GROUP BY VehicleId,Registration,VehicleTypeID,DaysNotPolled,LastPoll,PollLat,PollLon,PollLocation,FirmwareVersion,Ignition,OdoGPS,OdoCAN,   
			DriverIdCount,IdDistance,NoIdDistance,NoIdLatestTime,DrivingFuel, AverageEngineRPM, iButton,Tacho,CheetahFaults,SS1Faults,
			Sensor01,Sensor01Faults,Sensor02,Sensor02Faults,Sensor03,Sensor03Faults,Sensor04,Sensor04Faults,DistanceUnit,FuelUnit,LiquidUnit,Co2Unit,co.CheckoutReason
    ORDER BY DaysNotPolled DESC
GO
