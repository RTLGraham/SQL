SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ReportSpeedingVehiclesIVH]
	-- Add the parameters for the stored procedure here
	@vid NVARCHAR(MAX) = NULL, 
    @uid UNIQUEIDENTIFIER = NULL,
	@sdate DATETIME = NULL, 
	@edate DATETIME = NULL,
	@highonly BIT = NULL
AS

	--/* Test data */
	--DECLARE @vid NVARCHAR(max),
	--		@uid UNIQUEIDENTIFIER,
	--		@sdate DATETIME,
	--		@edate DATETIME,
	--		@highonly BIT	 

	--/*DGD - high events*/
	--SET @vid = N'B32141A6-1713-4CE9-BB71-822261F39891'
	--SET @uid = N'2A1588D7-DE7F-4014-BAA9-CDD64FB4C183'
	--SET @sdate = '2018-10-10 00:00'
	--SET @edate = '2018-10-10 23:59'
	--SET @highonly = 0

	/* Swap parameters */
	DECLARE	@lsdate DATETIME,
			@ledate DATETIME,
			@luid UNIQUEIDENTIFIER,
			@lvid VARCHAR(MAX)

	SET @lsdate = @sdate
	SET @ledate = @edate
	SET @luid = @uid
	SET @lvid = @vid

	/* Declare and Set essential variables */
	DECLARE @speedunit VARCHAR(10), 
			@timezone VARCHAR(255),
			@s_date DATETIME,
			@e_date DATETIME,
			@speedmult FLOAT,
			@vehicleId UNIQUEIDENTIFIER,
			@did INT,
			@sql NVARCHAR(MAX),
			@eventtime DATETIME, 
			@depid INT,
			@cid UNIQUEIDENTIFIER,
			@thpercent FLOAT,
			@thvalue FLOAT,
			@thpercentValue FLOAT,
			@thvalueValue FLOAT

	SELECT @speedunit = dbo.UserPref(@luid, 209)
	SELECT @timezone = dbo.UserPref(@luid, 600)
	SET @s_date = [dbo].TZ_ToUTC(@lsdate,@timezone,@luid)
	SET @e_date = [dbo].TZ_ToUTC(@ledate,@timezone,@luid)
	SET @speedmult = CAST([dbo].[UserPref](@luid,208) AS FLOAT)
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
			CAST(e.Speed * @speedmult AS INT) AS Speed,  
			[dbo].[GetCMD_IVH_Overspeed](v.VehicleId, e.EventDateTime, e.Speed) * @speedmult AS SpeedLimit,
			[dbo].[TZ_GetTime]( e.EventDateTime, @timezone, @luid) AS EventDateTime, 
			e.Lat,  
			e.Long AS SafeNameLong,  
            e.Heading,
			@speedunit AS SpeedUnit,  
			[dbo].[GetGeofenceNameFromLongLat] (e.Lat, e.Long, @uid, [dbo].[GetAddressFromLongLat] (e.Lat, e.Long)) AS RevGeocode,
			dbo.FormatDriverNameByUser(
				dbo.GetCurrentDriverByEventDateTime( e.VehicleIntId, ISNULL(i.IVHTypeId,0), e.EventDateTime, d.DriverId ),
				@luid) AS Drivername,
			CAST(0 AS BIT) AS IsHigh
	FROM	dbo.Event e WITH (NOLOCK)
				LEFT OUTER JOIN dbo.Driver d ON e.DriverIntId = d.DriverIntId
				INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
				/* LEFT JOIN to support cameras*/
				LEFT OUTER JOIN dbo.IVH i ON v.IVHId = i.IVHId
				INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
				INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId AND e.CustomerIntId = c.CustomerIntId 
	WHERE	e.EventDateTime BETWEEN @s_date AND @e_date
			AND e.CreationCodeId = 39  
			AND v.VehicleId IN (SELECT VALUE FROM dbo.Split(@vid, ',')) 
			AND e.Speed <= e.MaxSpeed
	ORDER BY e.EventDateTime ASC


GO
