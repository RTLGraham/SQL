SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Driver_GetVehicleLogonEvent]
(
	@did UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME
)
AS

		SELECT	e.EventId,
				v.VehicleId,
				d.DriverId,
				e.CreationCodeId,
				e.EventDateTime,
				d.Surname,
				d.Number,
				e.CustomerIntId
		FROM [dbo].[Event] e
		INNER JOIN [dbo].[Driver] d ON e.DriverIntId = d.DriverIntId
		INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
		WHERE d.driverid = @did
		AND e.eventdatetime BETWEEN @sdate AND @edate



GO
