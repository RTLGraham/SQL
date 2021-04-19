SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		<Dmitrijs Jurins>
-- Create date: <2011-02-01>
-- Description:	<Get raw Event for speeding analysis>
-- =============================================
CREATE PROCEDURE [dbo].[proc_GetRawEventForSpeeding_DDS]
	@sdate DATETIME,
	@edate DATETIME,
	@dispatcher NVARCHAR(1024) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	--DECLARE @sdate DATETIME, @edate DATETIME
	--SET @sdate = DATEADD (mi, -100, GETUTCDATE()) 
	--SET @edate = GETUTCDATE()
	
	SELECT 
		e.CustomerIntId, 
		v.VehicleId, 
		e.EventId, 
		e.Lat, 
		e.Long AS Lon, 
		e.Speed, 
		--CASE WHEN i.IVHTypeId = 5 THEN CAST(e.MaxSpeed AS TINYINT) ELSE CAST(e.Speed AS TINYINT) END AS MaxSpeed, 
		--ISNULL(e.MaxSpeed, CAST(e.Speed AS TINYINT)) AS MaxSpeed,
		--ISNULL(CASE WHEN e.MaxSpeed = 0 THEN CAST(e.Speed AS TINYINT) ELSE e.MaxSpeed END, CAST(e.Speed AS TINYINT)) AS MaxSpeed,
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
		ISNULL(v.VehicleTypeID, 2100000) AS VehicleType
	FROM dbo.Event e
		INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
		LEFT OUTER JOIN dbo.IVH i ON v.IVHId = i.IVHId
		INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
		LEFT OUTER JOIN dbo.EventSpeeding es ON es.EventId = e.EventId 
	WHERE e.EventDateTime BETWEEN @sdate AND @edate 
--	and e.speedlimit < 200
		AND (e.Lat != 0 AND e.Long != 0)
		AND e.Speed >= 10
		AND e.CreationCodeId NOT IN (100, 0, 24, 101)
		AND v.Archived = 0
		AND cv.Archived = 0
		AND cv.EndDate IS NULL
		AND e.SpeedLimit IS NULL
		AND es.SpeedLimit IS NULL	
		AND (c.OverSpeedValue IS NOT NULL OR c.OverSpeedPercent IS NOT NULL) -- Speeding is enabled for the Customer
	    AND (c.DataDispatcher = @dispatcher OR @dispatcher IS NULL)
	order by vehicleid, eventdatetime

END

GO
