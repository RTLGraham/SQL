SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Dmitrijs Jurins, Graham Pattison>
-- Create date: <2015-05-12>
-- Description:	<Gets only the events which LatLonIdx is not present in the reverse geocode database>
-- =============================================
CREATE PROCEDURE [dbo].[proc_RevGeocodeListMissing] 
(
	@LastTime DATETIME,
	@dispatcher NVARCHAR(1024) = NULL
)
AS
BEGIN

	--DECLARE @LastTime DATETIME
	--SET @LastTime = DATEADD(MINUTE, -5, GETDATE())

	DECLARE @maxEventId BIGINT,
			@eventId BIGINT
	SELECT @maxEventId = MAX(EventId) FROM dbo.Event WITH (NOLOCK)

	SELECT @eventId = @maxEventId - SUM(EventCount)
	FROM dbo.BulkInserts WITH (NOLOCK)
	WHERE InsertDateTime BETWEEN @LastTime AND GETDATE()

	SELECT e.Lat, e.Long
	FROM dbo.Event e WITH (NOLOCK)
	INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
	INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
	INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
	LEFT JOIN dbo.RevGeocode r --ON e.Lat = r.Lat AND e.Long = r.Long
								 ON CAST((e.Lat + 90) * 1000 as bigint)*1000000+CAST((e.Long + 180) * 1000 as bigint) = r.LatLongIdx
	WHERE e.EventId > @eventId
	  AND e.CreationCodeId IN (3,4,5)
	  AND r.Lat IS NULL AND r.Long IS NULL
	  AND e.Lat != 0 AND e.Long != 0
	  AND (c.DataDispatcher = @dispatcher OR @dispatcher IS NULL)

END





GO
