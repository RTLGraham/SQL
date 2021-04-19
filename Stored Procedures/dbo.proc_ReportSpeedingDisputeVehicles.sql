SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[proc_ReportSpeedingDisputeVehicles]
	-- Add the parameters for the stored procedure here
	@vid NVARCHAR(MAX) = NULL, 
    @uid UNIQUEIDENTIFIER = NULL,
	@sdate DATETIME = NULL, 
	@edate DATETIME = NULL,
	@highonly BIT = NULL
AS
BEGIN

-- GKP 02/01/19 Calculation Correction:
-- Calculation now takes unit of measure of the speedlimit from the EventSpeeding table as provided by the DDS system

	/* Test data */
	--DECLARE @vid NVARCHAR(max),
	--		@uid UNIQUEIDENTIFIER,
	--		@sdate DATETIME,
	--		@edate DATETIME,
	--		@highonly BIT	 

	--/*DGD - high events*/
	--SET @vid = N'3DFE6677-DD17-40AB-B673-C4563108F7D7'
	--SET @uid = N'710796B9-7EBC-4C04-B1BE-28EB9362D4EB'
	--SET @sdate = '2018-07-02 00:00'
	--SET @edate = '2018-07-02 08:59'
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

	-- Determine default speed unit for this database
	SELECT @speedunitdefault = Value
	FROM dbo.DBConfig
	WHERE NameID = 9001

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
			ISNULL(es.StreetName,ISNULL([dbo].[GetNavteqAddressFromLongLat] (es.Lat, es.Lon), 
				[dbo].[GetGeofenceNameFromLongLat] (es.Lat, es.Lon, @uid, [dbo].[GetAddressFromLongLat] (es.Lat, es.Lon))
				)) AS RevGeocode,
			dbo.FormatDriverNameByUser(
				dbo.GetCurrentDriverByEventDateTime( es.VehicleIntId, ISNULL(i.IVHTypeId,0), es.EventDateTime, d.DriverId ),
				@luid) AS Drivername,
			CASE WHEN @thpercentValue IS NULL
				THEN
					CASE WHEN ROUND(es.Speed, 0, 1) > (es.SpeedLimit / CASE WHEN ISNULL(es.SpeedUnit, @speedunitdefault) = 'M' THEN 0.6214 ELSE 1 END) + @thvalueValue THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
				ELSE
					CASE WHEN ((es.Speed * 100) / dbo.ZeroYieldNull(es.SpeedLimit / CASE WHEN ISNULL(es.SpeedUnit, @speedunitdefault) = 'M' THEN 0.6214 ELSE 1 END)) - 100 > @thpercentValue THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
			END AS IsHigh,
			es.EventId,
			ISNULL(es.ChallengeInd, 0) AS IsDispute,
			sds.Name AS DisputeStatus,
			es.SpeedingDisputeTypeId,
			sdt.Name AS DisputeType
	FROM	dbo.EventSpeeding es WITH (NOLOCK)
				INNER JOIN dbo.SpeedingDisputeStatus sds ON es.ChallengeInd = sds.SpeedingDisputeStatusId
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
	ORDER BY v.Registration, es.EventDateTime ASC
END

GO
