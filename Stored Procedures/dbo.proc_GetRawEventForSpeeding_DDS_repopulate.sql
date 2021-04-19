SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		<Dmitrijs Jurins>
-- Create date: <2015-02-27>
-- Description:	<Get raw Event for speeding analysis>
-- =============================================
CREATE PROCEDURE [dbo].[proc_GetRawEventForSpeeding_DDS_repopulate]
	@vids NVARCHAR(MAX),
	@sdate DATETIME,
	@edate DATETIME
AS
BEGIN
	SET NOCOUNT ON;
	
	--DECLARE @sdate DATETIME, @edate DATETIME, @vids NVARCHAR(MAX)
	--SET @sdate = DATEADD (mi, -1000, GETUTCDATE()) 
	--SET @edate = GETUTCDATE()
	--SET @vids = N'6CD1331B-F7FC-4866-A333-8FEE45667F33,0FADC446-F107-4EF5-B23A-93CF7EA917E7'
	
	SELECT 
		e.CustomerIntId, 
		v.VehicleId, 
		e.EventId, 
		e.Lat, 
		e.Long AS Lon, 
		e.Speed, 
		--CASE WHEN i.IVHTypeId = 5 THEN CAST(e.MaxSpeed AS TINYINT) ELSE CAST(e.Speed AS TINYINT) END AS MaxSpeed, 
		ISNULL(e.MaxSpeed, CAST(e.Speed AS TINYINT)) AS MaxSpeed,
		e.Heading, 
		e.EventDateTime, 
		e.SpeedLimit,
		ISNULL(v.VehicleTypeID, 2100000) AS VehicleType
	FROM dbo.Event e
		INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
		INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId 
	WHERE e.EventDateTime BETWEEN @sdate AND @edate 
--	and e.speedlimit < 200
		AND (e.Lat != 0 AND e.Long != 0)
		AND e.Speed >= 10
		AND e.CreationCodeId NOT IN (100, 0, 24)
		AND v.Archived = 0
		AND cv.Archived = 0
		AND cv.EndDate IS NULL
		AND v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
		AND (c.OverSpeedValue IS NOT NULL OR c.OverSpeedPercent IS NOT NULL) -- Speeding is enabled for the Customer
	order by vehicleid, eventdatetime

END


GO
