SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportTemperatureStatus]
    (
      @vids VARCHAR(MAX),
      @uid UNIQUEIDENTIFIER,
      @isAlert BIT,
      @isChecked BIT,
      @date DATETIME = NULL
    )
AS 
--DECLARE	@vids VARCHAR(MAX),
--		@uid UNIQUEIDENTIFIER,
--		@isAlert BIT,
--		@isChecked BIT,
--		@date DATETIME
------
----SET @vids = N'6CD1331B-F7FC-4866-A333-8FEE45667F33,6913DDBF-6FAC-4E5B-A33D-0D61CA692791,8016F50D-A2D1-49A9-BC1E-13AE27953390,486A43F1-70D9-46CC-A745-542B6A4D77CE,5DE385BF-BFCB-4179-90CB-5AEE460B14AD,67B44E7F-6A0E-42E0-9DCF-5DDCA2AF502E,2C1A82DE-6DCB-4D03-BC21-5F65198B9A84,DB3AC174-1CFE-404C-914B-6BE9DB1B7038,D075F7EF-C02E-46E4-91C3-8191F2167F59,6CD1331B-F7FC-4866-A333-8FEE45667F33,3708F23A-F7CA-44F0-BB96-A94E80C40DFF,5AAB0E74-D39E-483B-AAFF-200FB5A56850,1860348D-20B5-42CF-BA66-203864BA0461,BD5F9889-8007-4943-9001-46CB3ED2D36F,4DA5FA6D-8496-4D75-AA6A-4C32B377BDF9,C5868274-5850-4762-8EA8-5B5B7C1C2B5B,BD15D85F-F591-4AB5-881A-65E296715D18,33A67A70-9935-4214-B7B0-69B7AC228F5C,46F9F76A-1324-474B-B0BD-6E160C3E8ACD,EB5F8AE0-FC95-4D38-87FE-801C22911CA6,2D68CB77-FE15-4030-839A-824B6D0806BA,9A615ECD-2389-4D20-B0BE-8667626A38BA,CF6E7729-C9E7-4373-BEAB-895D9A2F1379,8288801A-186F-4BE4-A044-8A4007BD2372,0BBEF81F-92A9-4183-A354-8B15F4B354DD,AE9AD52F-7659-4339-BB56-A39AC3923A54,DF0D3E78-19EB-4779-BAE8-A974FE4F1B33,F5F18987-540E-44A0-A9EB-BC42699EFA30,2E7A5E82-702A-4003-BB17-C072A93ED941,18750389-36C6-4D3E-BE79-C54B859CE83B,2C63EBDD-07D4-4F26-A3A4-C5E18DBCB5CF,0A293ED6-5DE5-4B92-BDF0-C8357DF9003D,D103A123-A2A2-4EF1-97DF-D184E971FE7B,C98B01D1-B2E7-4378-A1A4-D5245CDDDF0D,3AAEA81D-20C4-4F24-B022-DECA9C7C51B1,5081472D-203E-4F21-9CF8-E1F98619361A,53B878DA-091D-4722-B467-1463EE502C19,04D11745-A145-4215-A432-2A5061B9DC17,2C38D238-E1A6-4E08-B419-345ACB40930F,FA6E62CA-3470-4F73-A32D-3C79BF6206A9,339C8146-9790-4CFE-B974-5819ECC299C0,C83D509F-26C0-4ED6-9D12-5C5D9716789D,8780C077-1BCB-4EF9-AC7A-6D763D0B5721,FB0C91E1-401B-427B-B3EE-7AC8A4294BF3,7DE5AA38-2BA3-4C8F-A488-911911DA6F80,0FADC446-F107-4EF5-B23A-93CF7EA917E7,5C77C772-4FCA-4040-BDF7-942B2E153FFF,B88446F6-CDEE-456D-9896-9743AEDD4D9A,8C2E8B0E-E258-4F27-8BE6-9EE90EF08614,DB306411-629E-445B-8FE9-9FE65C285296,4723BA01-21CE-4FFB-85E7-A754BF858BC7,97E3C42B-0940-404F-B0FE-E4AD4981E728,76EE70C2-598A-4C1F-85C0-E5A102CD70F2,B7EEE367-B07C-4441-86EF-EB7E5613F7EF,7B27F3D7-3BAC-40AC-9B30-ED9211329331,ABAC69E6-CCCC-4E60-9F81-0B14A2CE8CFD,7A03DFD2-3982-46E8-8C4E-12F297DEE350,16DF929B-A773-46D2-900E-2CA8DCF23893,87A3B70E-9B8D-42CB-BB13-2E1C9427331C,93431E81-EE44-4EEE-A959-387B6E4F9CE3,39512BD9-7CCF-48AD-9623-46CD000D2AC6,C7343CE2-50EF-4AA2-AAAC-736442ECFA0A,9B2B5A35-D0D9-4776-BB1F-87B27DBFD2CC,D92E730A-EAA8-4675-A625-9F9F7E6E7B16,DFB2454E-1286-473B-9215-A38D8717CE57,42C9DA5C-2BF6-4A23-865A-A5AB067F8DFA,B8C522B8-99C0-4630-A4DE-A7A523437829,3D0FA257-E0E9-4009-9508-BBFFA244F817,87B51B30-B441-4A79-AD36-ED2BAD3E3204,9264E0AD-E96D-4974-B0FD-1E50DDF18BDD,9BBD17D4-3BE2-4E29-B550-509AB56CA92F,AC4A7F16-ACAF-41E5-B7CB-57C1C3123C20,A158F8A8-D73B-4EEF-962B-670C1BAB6696,AB2E895D-CB6F-4BD9-8CF1-71E976E6F335,A2A7640A-7CD1-48D3-8270-80A8F2C9FA63,4DD73B7F-2FC4-4F06-B888-A4C4AA923C58,6CC1F03D-9CCB-47CB-8796-C641A5B951C3,BF808915-A86D-4EB8-9804-C64375223662,383FC529-05E2-4F17-ABD5-C9E08895E29D,EA9340A7-EA1D-43F1-A213-E95B7BE2225E,3554137E-4695-46AC-A678-F6428E995B91,9F754430-BDF3-4F5A-9454-092C21FE247A,3636AE89-04DF-4AE1-95AB-2C06253041BA,2F060A96-D3F8-4363-88D1-86D6F605976E,77A0110C-5D6C-493A-9C16-8A59A9ABD5B4,D622FBC6-9804-4298-B7D8-B83A04A1E620,D5C0A3B0-0996-4D3C-B7F5-BC360B98B024,223B3FF2-E259-4460-B4BD-C6979B626432,79626E6C-F770-4223-A2F8-DFDD491578EF,53D2962E-9E72-466E-B703-E5BA47474BAD,9208ED3D-1CD6-41B1-B8F4-EDC4F5141869,A2609578-A02A-4150-8525-F86F3E0C2177,5F3CEA35-DCBE-4120-9301-09FF638BF9DF,46D70EB7-624A-4F2D-92D7-1DB630EE116F,9DFE074E-F8B7-44C0-8BAA-3FB046ED29A2,49482BB6-B7CC-40C1-9F61-48728BF61A8E,F30F1966-C7B8-4980-BFFE-5B930071D32D,991F0624-E911-4A0A-9E34-632B912A9C38,202B4D58-3993-43D1-A8C5-7BC46C7CEFA5,747C1E8B-7F86-4BB3-9AC3-8C4E319272B2,1D3D521A-9CFF-4B73-BC2E-97ADB314A3A2,767A5BB3-0077-4799-AC91-9E88279E99F1,7F0079D1-5D4E-47D8-AFEA-A9835C3A3D00,09504D20-457C-49EC-A6EE-CC7DAA4C4252,28E3452A-A515-45BC-B95F-DED8A0EB1CD8,2F29E214-4249-4412-9927-1BBFF111DF1B,2FE4DD9B-905F-477A-A710-218A4E5C6750,D1742CC9-A5E3-434E-A9E8-3A1D858B1DE4,BF48CB72-BEC8-475E-A8E3-511D485F15BF,68CF88EA-D828-4D33-A849-9441A63D5E8D,061C8BAA-F34C-468E-BB72-9C4162664851,3FF3032B-D9DC-4FE8-834B-A6EB6FC3C7CB,D9FFD177-BC18-4348-A771-D18F39522D6B,074D27DA-97B6-42FC-920E-EEF395553804,250F5527-CF24-427E-A514-F52F42E7B51A,B639621D-7C4D-4B91-8DDF-486051D96448,24D1F780-C878-4FF0-A6D8-68B5FDA92CBB,F16007E6-0BED-44B4-8725-AE703F1F2285,909FB8A2-A973-4253-99C1-03EAF670C13B,FE456C02-2AC4-4813-9473-13F82137005A,AD7AE29D-1328-4228-B4C2-194D6C90A266,EF8191E1-ABED-480F-99C3-243BC4E7EEE7,7D5C3C05-221C-47EF-8DAC-278789C406AE,AF6A1AEC-0BF5-4224-8A04-2BF2659C2739,A1AE4401-9643-4A36-94C7-3E93BE0646C4,5146C0B8-5CE5-44E1-A6C6-41D2E201EF76,2E7984F5-D541-4070-969B-4DEFA0130CB5,14337BBF-9F3F-4624-9B84-73CB3485BDEE,6F6C50EC-608F-4528-A69C-838BDBECAAF5,02F1446D-BB14-4B9F-9D72-8C13BBFDF9D7,6659A865-3221-4DC1-8682-92B1AEA9251E,284944F1-4BB4-4ED7-B49D-9E318203E950,74EEE16C-CF22-4DE3-B677-B5BBC86BBDC4,EF7D5DF1-3744-4233-ADAE-C6A24B16B87B,B52C20AA-96D0-4249-8EC1-C7751A385D87,49D600B5-E440-4A61-BF2F-D2C78BA278E6,88EADF4C-8B3E-488D-A755-E05AB60B3AE0,37415C60-7E05-4F91-8A32-F26DF518CF80,5632AB2C-95E1-4D21-BA04-F6104F5238CC'
--SET @vids = N'A5D7830A-69D3-425E-9775-CFB025BB7D19,67B44E7F-6A0E-42E0-9DCF-5DDCA2AF502E,BAE976F9-38BF-466C-ADA7-DA3CD8EA0E79'
--SET @uid = N'3DB40C4A-7E79-4F41-8017-DE6E12EC7A20'
--SET @isAlert = NULL
--SET @isChecked = NULL
--SET @date = '2021-01-26 00:00'

    SET @date = dbo.TZ_ToUtc(ISNULL(@date, GETDATE()), DEFAULT, @uid)

    SET @isAlert = ISNULL(@isAlert, 0)
    SET @isChecked = ISNULL(@IsChecked, 0)

    DECLARE @tempmult FLOAT,
        @liquidmult FLOAT
    SET @tempmult = ISNULL(dbo.[UserPref](@uid, 214), 1)
    SET @liquidmult = ISNULL(dbo.[UserPref](@uid, 200),
                             1)

    DECLARE @AnalogAlert1 SMALLINT,
        @AnalogAlert2 SMALLINT,
        @AnalogAlert3 SMALLINT,
        @AnalogAlert4 SMALLINT
    SET @AnalogAlert1 = 1
    SET @AnalogAlert2 = 2
    SET @AnalogAlert3 = 4
    SET @AnalogAlert4 = 8

-- Create a table variable and populate with the temperature alert status at the given date
    DECLARE @TemperatureAlert TABLE
        (
          VehicleId UNIQUEIDENTIFIER,
          VehicleIntId INT,
          EventId BIGINT
        )

    INSERT  INTO @TemperatureAlert
            (
              VehicleId,
              VehicleIntId,
              EventId
            )
            SELECT  v.VehicleId,
                    v.VehicleIntId,
                    MAX(e.EventId)
            FROM    dbo.Vehicle v
                    INNER JOIN dbo.Event e ON v.VehicleIntId = e.VehicleIntId
                                                           AND e.EventDateTime <= @date
            WHERE   v.VehicleId IN ( SELECT VALUE
                                     FROM   dbo.Split(@vids, ',') )
--  AND e.EventDateTime <= @date
            GROUP BY v.VehicleId,
                    v.VehicleIntId


DECLARE @results TABLE
(
	VehicleId UNIQUEIDENTIFIER,
	VehicleIntId INT,
	Registration NVARCHAR(MAX),
    AnalogAlert1Name NVARCHAR(MAX),
    AnalogAlert1Colour NVARCHAR(MAX),
    AnalogAlert1Status BIT,
    AnalogAlert2Name NVARCHAR(MAX),
    AnalogAlert2Colour NVARCHAR(MAX),
    AnalogAlert2Status BIT,
    AnalogAlert3Name NVARCHAR(MAX),
    AnalogAlert3Colour NVARCHAR(MAX),
    AnalogAlert3Status BIT,
    AnalogAlert4Name NVARCHAR(MAX),
    AnalogAlert4Colour NVARCHAR(MAX),
    AnalogAlert4Status BIT,
    Ack BIT,
    AckReason NVARCHAR(MAX),
    AckDateTime DATETIME,
    AckUserName NVARCHAR(MAX),
    AnalogIoAlertTypeId INT,
    AlertStatusTime DATETIME,
    CheckInOut BIT,
    CheckInOutReason NVARCHAR(MAX),
    CheckInOutDateTime DATETIME,
    CheckInOutExpiryDateTime DATETIME,
    CheckInOutUserName NVARCHAR(MAX),
    SensorTime DATETIME,
    Sensor01Value FLOAT,
    Sensor02Value FLOAT,
    Sensor03Value FLOAT,
    Sensor04Value FLOAT
)

INSERT INTO @results
        ( VehicleId ,
		  VehicleIntId,
          Registration ,
          AnalogAlert1Name ,
          AnalogAlert1Colour ,
          AnalogAlert1Status ,
          AnalogAlert2Name ,
          AnalogAlert2Colour ,
          AnalogAlert2Status ,
          AnalogAlert3Name ,
          AnalogAlert3Colour ,
          AnalogAlert3Status ,
          AnalogAlert4Name ,
          AnalogAlert4Colour ,
          AnalogAlert4Status ,
          Ack ,
          AckReason ,
          AckDateTime ,
          AckUserName ,
          AnalogIoAlertTypeId ,
          AlertStatusTime ,
          CheckInOut ,
          CheckInOutReason ,
          CheckInOutDateTime ,
          CheckInOutExpiryDateTime ,
          CheckInOutUserName ,
          SensorTime ,
          Sensor01Value ,
          Sensor02Value ,
          Sensor03Value ,
          Sensor04Value
        )
SELECT  v.VehicleId,
		v.VehicleIntId,
        v.Registration,
        dbo.CFG_GetTemperatureAlertValueFromHistory(v.VehicleId, 'Name_1', @date) AS AnalogAlert1Name,
        dbo.CFG_GetTemperatureAlertValueFromHistory(v.VehicleId, 'Colour_1', @date) AS AnalogAlert1Colour,
        dbo.TestBits(e.AnalogData5, @AnalogAlert1) AS AnalogAlert1Status,
        dbo.CFG_GetTemperatureAlertValueFromHistory(v.VehicleId, 'Name_2', @date) AS AnalogAlert2Name,
        dbo.CFG_GetTemperatureAlertValueFromHistory(v.VehicleId, 'Colour_2', @date) AS AnalogAlert2Colour,
        dbo.TestBits(e.AnalogData5, @AnalogAlert2) AS AnalogAlert2Status,
        dbo.CFG_GetTemperatureAlertValueFromHistory(v.VehicleId, 'Name_3', @date) AS AnalogAlert3Name,
        dbo.CFG_GetTemperatureAlertValueFromHistory(v.VehicleId, 'Colour_3', @date) AS AnalogAlert3Colour,
        dbo.TestBits(e.AnalogData5, @AnalogAlert3) AS AnalogAlert3Status,
        dbo.CFG_GetTemperatureAlertValueFromHistory(v.VehicleId, 'Name_4', @date) AS AnalogAlert4Name,
        dbo.CFG_GetTemperatureAlertValueFromHistory(v.VehicleId, 'Colour_4', @date) AS AnalogAlert4Colour,
        dbo.TestBits(e.AnalogData5, @AnalogAlert4) AS AnalogAlert4Status,
        t.Ack,
        t.AckReason,
        [dbo].TZ_GetTime(t.AckDateTime, DEFAULT, @uid) AS AckDateTime,
        u1.FirstName + ' ' + u1.Surname AS AckUserName,
        vle.AnalogIoAlertTypeId,
        [dbo].TZ_GetTime(e.EventDateTime, DEFAULT, @uid) AS AlertStatusTime,
       CASE WHEN GETUTCDATE() BETWEEN ec.CheckOutDateTime AND ec.CheckInDateTime THEN 1 ELSE 0 END,
        ec.CheckOutReason AS CheckInOutReason,
        ec.CheckOutDateTime AS CheckInOutDateTime,
        ec.CheckInDateTime AS CheckInOutExpiryDateTime,
        u2.FirstName + ' ' + u2.Surname AS CheckInOutUserName,
        vle.EventDateTime AS SensorTime,
        dbo.GetScaleConvertAnalogValue(ISNULL(t.AnalogData0, vle.AnalogData0),
                                                    0, v.VehicleId,
                                                    @tempmult, @liquidmult) AS Sensor01Value,
        dbo.GetScaleConvertAnalogValue(ISNULL(t.AnalogData1, vle.AnalogData1),
                                                    1, v.VehicleId,
                                                    @tempmult, @liquidmult) AS Sensor02Value,
        dbo.GetScaleConvertAnalogValue(ISNULL(t.AnalogData2, vle.AnalogData2),
                                                    2, v.VehicleId,
                                                    @tempmult, @liquidmult) AS Sensor03Value,
        dbo.GetScaleConvertAnalogValue(ISNULL(t.AnalogData3, vle.AnalogData3),
                                                    3, v.VehicleId,
                                                    @tempmult, @liquidmult) AS Sensor04Value
FROM    dbo.VehicleLatestEvent vle
        INNER JOIN dbo.Vehicle v ON vle.VehicleId = v.VehicleId
        INNER JOIN @TemperatureAlert ta ON v.VehicleId = ta.VehicleId
        INNER JOIN dbo.Event e ON ta.VehicleIntId = e.VehicleIntId
                                               AND ta.EventId = e.EventId
        LEFT JOIN dbo.TemperatureStatus t ON v.VehicleId = t.VehicleId
                                                          AND t.AckDateTime > CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-' + CAST(dbo.LeadingZero(MONTH(GETDATE()), 2) AS VARCHAR(2)) + '-' + CAST(dbo.LeadingZero(DAY(GETDATE()), 2) AS VARCHAR(2)) + ' 00:00:00.000'
        LEFT JOIN dbo.TAN_EntityCheckOut ec ON v.VehicleId = ec.EntityId
                                                            AND (GETUTCDATE() BETWEEN ec.CheckOutDateTime
                                                                             AND     ISNULL(ec.CheckInDateTime, '2099-21-31 00:00') OR GETUTCDATE()< ec.CheckOutDateTime)
        LEFT JOIN dbo.[User] u1 ON t.AckUserId = u1.UserID
        LEFT JOIN dbo.[User] u2 ON ec.CheckOutUserId = u2.UserID
WHERE   v.VehicleId IN ( SELECT VALUE
                         FROM   dbo.Split(@vids, ',') )
        AND 1 = CASE @isAlert
                  WHEN 0 THEN 1 -- show ALL vehicles
		--ELSE CASE WHEN (vle.AnalogIoAlertTypeId IS NULL) THEN 0 ELSE 1 END -- only alerted vehicles
                  ELSE CASE WHEN ( dbo.TestBits(e.AnalogData5,
                                                @AnalogAlert1) = 1
                                   OR dbo.TestBits(e.AnalogData5,
                                                   @AnalogAlert2) = 1
                                   OR dbo.TestBits(e.AnalogData5,
                                                   @AnalogAlert3) = 1
                                   OR dbo.TestBits(e.AnalogData5,
                                                   @AnalogAlert4) = 1
                                 ) THEN 1
                            ELSE 0
                       END -- only alerted vehicles
                END
        AND 1 = CASE @isChecked
                  WHEN 0 THEN 1 -- show ALL vehicles
                  ELSE CASE WHEN ( ec.EntityCheckOutId IS NULL ) THEN 0
                            ELSE 1
                       END -- only checked out vehicles
                END

DECLARE @VehicleIntId INT, 
		@VehicleId UNIQUEIDENTIFIER,
		@Sensor01Value_New FLOAT, 
		@Sensor02Value_New FLOAT, 
		@Sensor03Value_New FLOAT, 
		@Sensor04Value_New FLOAT, 
		@SensorTime DATETIME, 
		@SensorTime_New DATETIME
		
DECLARE data_cur CURSOR FAST_FORWARD FOR
SELECT VehicleId, VehicleIntId, SensorTime FROM @results


OPEN data_cur
FETCH NEXT FROM data_cur INTO @VehicleId, @VehicleIntId, @SensorTime
WHILE @@fetch_status = 0
BEGIN
	SET @Sensor01Value_New = NULL
	SET @Sensor02Value_New = NULL
	SET @Sensor03Value_New = NULL
	SET @Sensor04Value_New = NULL
			
	SELECT TOP 1 @Sensor01Value_New = dbo.GetScaleConvertAnalogValue(e.AnalogData0, 0, @VehicleId, @tempmult, @liquidmult), 
				 @Sensor02Value_New = dbo.GetScaleConvertAnalogValue(e.AnalogData1, 1, @VehicleId, @tempmult, @liquidmult), 
				 @Sensor03Value_New = dbo.GetScaleConvertAnalogValue(e.AnalogData2, 2, @VehicleId, @tempmult, @liquidmult), 
				 @Sensor04Value_New = dbo.GetScaleConvertAnalogValue(e.AnalogData3, 3, @VehicleId, @tempmult, @liquidmult),
				 @SensorTime_New = e.EventDateTime
	FROM dbo.Event e
	WHERE e.VehicleIntId = @VehicleIntId
		AND e.EventDateTime BETWEEN @SensorTime AND GETDATE()
	ORDER BY EventDateTime DESC
	
	IF  @Sensor01Value_New IS NOT NULL AND
		@Sensor02Value_New IS NOT NULL AND
		@Sensor03Value_New IS NOT NULL AND
		@Sensor04Value_New IS NOT NULL AND
		@SensorTime_New IS NOT NULL
		BEGIN
			UPDATE @results
			SET Sensor01Value = @Sensor01Value_New,
				Sensor02Value = @Sensor02Value_New,
				Sensor03Value = @Sensor03Value_New,
				Sensor04Value = @Sensor04Value_New,
				SensorTime = @SensorTime_New
			WHERE VehicleIntId = @VehicleIntId
		END
		
	FETCH NEXT FROM data_cur INTO @VehicleId, @VehicleIntId, @SensorTime
END
CLOSE data_cur
DEALLOCATE data_cur

SELECT	  VehicleId ,
          Registration ,
          AnalogAlert1Name ,
          AnalogAlert1Colour ,
          AnalogAlert1Status ,
          AnalogAlert2Name ,
          AnalogAlert2Colour ,
          AnalogAlert2Status ,
          AnalogAlert3Name ,
          AnalogAlert3Colour ,
          AnalogAlert3Status ,
          AnalogAlert4Name ,
          AnalogAlert4Colour ,
          AnalogAlert4Status ,
          Ack ,
          AckReason ,
          AckDateTime ,
          AckUserName ,
          AnalogIoAlertTypeId ,
          AlertStatusTime ,
          CheckInOut ,
          CheckInOutReason ,
          dbo.TZ_GetTime(CheckInOutDateTime, DEFAULT, @uid) AS CheckInOutDateTime ,
          dbo.TZ_GetTime(CheckInOutExpiryDateTime, DEFAULT, @uid) AS CheckInOutExpiryDateTime ,
          CheckInOutUserName ,
          dbo.TZ_GetTime(SensorTime, DEFAULT, @uid) AS SensorTime,
          --Why was it added twice?
		  --SensorTime ,
          Sensor01Value ,
          Sensor02Value ,
          Sensor03Value ,
          Sensor04Value
FROM @results          

GO