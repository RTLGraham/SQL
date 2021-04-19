SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportSpeedingVehicles]
	-- Add the parameters for the stored procedure here
	@vid NVARCHAR(MAX) = NULL, 
    @uid UNIQUEIDENTIFIER = NULL,
	@sdate DATETIME = NULL, 
	@edate DATETIME = NULL,
	@highonly BIT = NULL
AS
BEGIN

-- GKP 02/01/19 Calculation Correction: Calculation now takes unit of measure of the speedlimit from the EventSpeeding table as provided by the DDS system
-- GKP 16/01/21 Completely revamped speeding process so that no longer need to join to Event table sor speeding data

	/* Test data */
	--DECLARE @vid NVARCHAR(max),
	--		@uid UNIQUEIDENTIFIER,
	--		@sdate DATETIME,
	--		@edate DATETIME,
	--		@highonly BIT	 

	--/*DGD - high events*/
	--SET @vid = N'829D376D-7C70-4A92-AD4E-2BDD095F4F50,7A9074E7-E953-47DA-BED3-54FAC3CCD8AA,F70E5615-6C85-47FB-8E4C-6A5CF8A0B297,27567277-DD51-4C0D-8FB4-6F10D81BC07D,72640C42-3AFD-443B-8A61-89E7B2D17560,286D3921-8E74-401F-924F-8FFFB76E9407,ED0D3A40-994F-48D3-A5F6-98A0151F46D5,D8DBC0D6-CB44-41AE-A668-9AB6B7EAFE5B,F589062A-A85A-4081-A1D8-A0306A3DBCFE,0A1FE368-5684-4D01-A8CE-A8E5D8276BD2,9B93494A-9E4B-40DC-B4AC-A9A09C7FA12F,9DD766AF-0C8D-4F45-9F15-A9D4F9EA3EB9,C404C3DE-1F11-4B27-A05A-AE2B00FB16C9,129E39A8-AEB2-4282-B296-BA09368C4192,F674F1D3-4127-4B24-969D-BD03E8772673,92FBA60A-944D-4656-A7B5-C6E33BEB62EC,072373EF-3BF3-414A-B238-CC3A7C8D1BF7,DE8F95D5-F40B-4D0B-B563-CD45A1D55135,ED47CE66-D869-40E7-8928-CECEC6F00059,FB98CA81-4967-4BB4-A976-D9FBE545E58D,265C735A-3EFC-499F-B823-ED1CF02AD4C4,1513E2CA-A07E-4C6D-ACE4-F172E863E9B5,CE94F088-06F3-45D7-8BE7-FC19EE341F91'
	--SET @uid = N'AC5FC459-FAF5-48D7-BBBE-88CC5EE824E1'
	--SET @sdate = '2020-12-01 00:00'
	--SET @edate = '2020-12-31 08:59'
	--SET @highonly = 0

	/* Swap parameters */
	DECLARE	@lsdate datetime,
			@ledate datetime,
			@luid UNIQUEIDENTIFIER,
			@lvid varchar(max)

	SET @lsdate = @sdate
	SET @ledate = @edate
	SET @luid = @uid
	SET @lvid = @vid

	/* Declare and Set essential variables */
	DECLARE @speedunit VARCHAR(10), 
			@timezone VARCHAR(255),
			@s_date DATETIME,
			@e_date DATETIME,
			@vehicleId UNIQUEIDENTIFIER,
			@did INT,
			@sql NVARCHAR(MAX),
			@eventtime DATETIME, 
			@depid INT,
			@cid UNIQUEIDENTIFIER,
			@thpercent FLOAT,
			@thvalue FLOAT,
			@thpercentValue FLOAT,
			@thvalueValue FLOAT,
			@speedunitdefault CHAR(1)

	
	SELECT @speedunitdefault = CASE DB_NAME() WHEN 'UK_Hubio_App' THEN 'M'
											  WHEN 'UK_Hubio_App' THEN 'M'
											  WHEN 'UK_Hubio_App' THEN 'M'
											  WHEN 'UK_Hubio_App' THEN 'M'
											  WHEN 'US_Fleetcam_App' THEN 'M'
											  ELSE 'K' END	
	SELECT @speedunit = dbo.UserPref(@luid, 209)
	SELECT @timezone = dbo.UserPref(@luid, 600)
	SET @s_date = [dbo].TZ_ToUTC(@lsdate,@timezone,@luid)
	SET @e_date = [dbo].TZ_ToUTC(@ledate,@timezone,@luid)
	--SET @speedmult = 1

	SELECT @cid = CustomerID FROM dbo.[User] WHERE UserID = @luid
	SELECT TOP 1	@thvalue =		CASE	WHEN @highonly = 1 
											THEN OverSpeedHighValue 
											ELSE OverSpeedValue END, 
					@thpercent =	CASE	WHEN @highonly = 1 
											THEN OverSpeedHighPercent 
											ELSE OverSpeedPercent END,
					@thpercentValue = OverSpeedHighPercent,
					@thvalueValue = OverSpeedHighValue
	FROM dbo.Customer 
	WHERE CustomerId = @cid

	IF @thpercent IS NULL SET @thpercent = 0
	IF @thvalue IS NULL SET @thvalue = 0

	SELECT	v.VehicleId,  
			v.Registration,  
			v.VehicleTypeID,
			CAST(es.Speed * CASE WHEN ISNULL(es.SpeedUnit, @speedunitdefault) = 'K' THEN 1 ELSE 0.6214 END AS INT) as Speed,  
			CAST(es.SpeedLimit AS INT) AS SpeedLimit,  
			[dbo].[TZ_GetTime]( es.EventDateTime, @timezone, @luid) as EventDateTime, 
			es.Lat,  
			es.Lon AS SafeNameLong,  
            es.Heading,
			@speedunit AS SpeedUnit,  
			es.StreetName  AS RevGeocode,
			dbo.FormatDriverNameByUser(d.DriverId,NULL)AS DriverName,
			CASE WHEN @thpercentValue IS NULL
				THEN
					CASE WHEN ROUND(es.Speed, 0, 1) > (es.SpeedLimit / CASE WHEN ISNULL(es.SpeedUnit, @speedunitdefault) = 'M' THEN 0.6214 ELSE 1 END) + @thvalueValue THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
				ELSE
					CASE WHEN ((es.Speed * 100) / dbo.ZeroYieldNull(es.SpeedLimit / CASE WHEN ISNULL(es.SpeedUnit, @speedunitdefault) = 'M' THEN 0.6214 ELSE 1 END)) - 100 > @thpercentValue THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
			END AS IsHigh,
			es.EventId,
			CAST(CASE WHEN ISNULL(es.ChallengeInd, 0) > 0 THEN 1 ELSE 0 END AS SMALLINT) AS IsDispute,
			sds.Name AS DisputeStatus,
			es.SpeedingDisputeTypeId,
			sdt.Name AS DisputeType
	FROM	dbo.EventSpeeding es WITH (NOLOCK) 
				LEFT OUTER JOIN dbo.SpeedingDisputeStatus sds ON es.ChallengeInd = sds.SpeedingDisputeStatusId
				LEFT OUTER JOIN	dbo.SpeedingDisputeType sdt ON sdt.SpeedingDisputeTypeId = es.SpeedingDisputeTypeId
				LEFT OUTER JOIN dbo.Driver d ON es.DriverIntId = d.DriverIntId
				INNER JOIN dbo.Vehicle v ON es.VehicleIntId = v.VehicleIntId
				/* LEFT JOIN to support cameras*/
				LEFT OUTER JOIN dbo.IVH i ON v.IVHId = i.IVHId
	WHERE	es.EventDateTime BETWEEN @s_date AND @e_date  
			AND v.VehicleId IN (SELECT VALUE FROM dbo.Split(@vid, ',')) 
			AND ((es.Speed * 100) / dbo.ZeroYieldNull(es.SpeedLimit / CASE WHEN ISNULL(es.SpeedUnit, @speedunitdefault) = 'M' THEN 0.6214 ELSE 1 END)) - 100 > @thpercent
			AND ROUND(es.Speed, 0, 1) > (es.SpeedLimit / CASE WHEN ISNULL(es.SpeedUnit, @speedunitdefault) = 'M' THEN 0.6214 ELSE 1 END) + @thvalue
			AND es.CreationCodeId NOT IN (100, 0, 24, 101)
			AND es.Speed < 250
			AND es.SpeedLimit < 250
	ORDER BY v.Registration, es.EventDateTime ASC
END


GO
