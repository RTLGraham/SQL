SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		<Jamie Bartleet>
-- Create date: <2018-08-30>
-- Description:	<Get raw Event for speeding analysis>
-- =============================================
CREATE PROCEDURE [dbo].[proc_GetRawEventForSpeeding_DDS_ReprocessPostedSpeedLimits]
	@dispatcher NVARCHAR(1024) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @dispatcher NVARCHAR(1024)

	DECLARE @customer NVARCHAR(100)	
	DECLARE @sdate DATETIME
	DECLARE @edate DATETIME

	SET @customer = 'Hoyer Poland AirLiquide'
	--SET @sdate = '2018-07-26 00:00:00' 
	--SET @edate = '2018-09-07 23:59:59'
	SET @sdate = '2018-09-20 00:00:00' 
	SET @edate = '2018-09-30 23:59:59'
	
	SELECT top 200
		e.CustomerIntId, 
		v.VehicleId, 
		e.EventId, 
		e.CreationCodeId,
		e.Lat, 
		e.Long AS Lon, 
		e.Speed, 
		CASE WHEN ISNULL(i.IVHTypeId, 0) = 5 
			THEN ISNULL(
					CASE WHEN e.MaxSpeed = 0 
						THEN CAST(dbo.CAP(ISNULL(e.Speed, 0), 255) AS TINYINT) 
						ELSE e.MaxSpeed 
					END, 
					CAST(dbo.CAP(ISNULL(e.Speed, 0), 255) AS TINYINT)) 
			ELSE CAST(dbo.CAP(ISNULL(e.Speed, 0), 255) AS TINYINT) 
		END AS MaxSpeed,
		ISNULL(e.Heading, 0) AS Heading, 
		e.EventDateTime, 
		e.SpeedLimit,
		es.PostedSpeedLimit,
		es.VehicleSpeedLimit,
		ISNULL(v.VehicleTypeID, 2100000) AS VehicleType
	FROM dbo.Event e WITH(NOLOCK)
		INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
		LEFT OUTER JOIN dbo.IVH i ON v.IVHId = i.IVHId
		INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
		LEFT OUTER JOIN dbo.EventSpeeding es ON es.EventId = e.EventId 
	WHERE e.EventDateTime BETWEEN @sdate AND @edate 
		and c.Name = @customer
		AND (c.OverSpeedValue IS NOT NULL OR c.OverSpeedPercent IS NOT NULL) -- Speeding is enabled for the Customer	    
		AND (e.Lat != 0 AND e.Long != 0)
		AND e.Speed >= 10
		AND e.CreationCodeId NOT IN (100, 0, 24, 101)
		and es.EventId is not null
		AND es.PostedSpeedLimit IS NULL	
		AND v.Archived = 0
		AND cv.Archived = 0
		AND cv.EndDate IS NULL
		--AND (c.DataDispatcher = @dispatcher OR @dispatcher IS NULL)
	order by vehicleid, eventdatetime

END

GO
