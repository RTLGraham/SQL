SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_LoneWorker_GetById]
(
	@lwid BIGINT
)
AS
	--DECLARE @lwid BIGINT
	--SET @lwid = 379

	SELECT	lw.LoneWorkerId,
			d.FirstName,
			d.Surname,
			lw.StartTime,
			lw.Duration,
			lw.AlarmTriggeredDateTime,
			lw.StopTime,
			lw.Lat,
			lw.Lon,
			dbo.[GetAddressFromLongLat] (lw.Lat, lw.Lon) AS ReverseGeocode,
			dbo.FormatUserNameByUser(lwa.UserId, lwa.UserId) AS AcknowledgedBy,
			t.Name AS AckStatus,
			lwa.ResponseDateTime,
			lwa.Comment
	FROM dbo.LW_LoneWorker lw
		INNER JOIN dbo.Driver d ON d.DriverId = lw.DriverId
		LEFT JOIN dbo.LW_LoneWorkerAck lwa ON lwa.LoneWorkerId = lw.LoneWorkerId
		LEFT JOIN dbo.LW_LoneWorkerResponseType t ON t.ResponseTypeId = lwa.ResponseTypeId
	WHERE lw.LoneWorkerId = @lwid

GO
