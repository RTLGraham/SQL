SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Dmitrijs Jurins>
-- Create date: <2011-02-01>
-- Description:	<Get raw Event for speeding analysis>
-- =============================================
CREATE PROCEDURE [dbo].[proc_GetRawEventForSpeeding]
	@sdate DATETIME,
	@edate DATETIME
AS
BEGIN
	SET NOCOUNT ON;
	
--	DECLARE @sdate DATETIME, @edate DATETIME
--	SET @sdate = '2014-04-08 10:00'
--	SET @edate = '2014-04-08 11:00'
	
	SELECT e.CustomerIntId, e.VehicleIntId, e.DriverIntId, c.CustomerId, v.VehicleId, e.EventId, e.Lat, e.Long AS Lon, e.Speed, e.MaxSpeed, e.Heading, e.EventDateTime, e.SpeedLimit,
		v.VehicleTypeID AS VehicleType
	FROM dbo.Event e
		INNER JOIN dbo.Customer c ON e.CustomerIntId = c.CustomerIntId
		LEFT OUTER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
		LEFT OUTER JOIN dbo.CustomerVehicle cv ON c.CustomerId = cv.CustomerId AND v.VehicleId = cv.VehicleId
	WHERE e.EventDateTime BETWEEN @sdate AND @edate
		AND (e.Lat != 0 AND e.Long != 0)
		AND e.Speed >= 10
		AND e.CreationCodeId NOT IN (100, 0, 24)
		AND v.Archived = 0
		AND cv.Archived = 0
		AND cv.EndDate IS NULL
		AND e.SpeedLimit IS NULL
		AND (c.OverSpeedValue IS NOT NULL OR c.OverSpeedPercent IS NOT NULL) -- Speeding is enabled for the Customer
END



GO
