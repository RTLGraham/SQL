SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_GetDailyDriverLogons]
(
	@VehicleId UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME = NULL,
	@depid INT = NULL
)
AS

IF @edate IS NULL
BEGIN
	SET @edate = DateAdd( second, -1, DateAdd(day, 1, @sdate))
END

IF @depid IS NULL
BEGIN
	SELECT @depid = dbo.GetCustomerIntId( @VehicleId, @edate )
END

SELECT v.VehicleId, d.DriverId, e.CreationCodeId, e.EventDateTime, d.Surname, d.Number, e.EventId, e.CustomerIntId
FROM [dbo].[Event] e
INNER JOIN [dbo].[Driver] d ON e.DriverIntId = d.DriverIntId
INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
WHERE e.CustomerIntId = @depid AND v.VehicleId = @VehicleId
AND EventDateTime BETWEEN @sdate AND @edate
AND (e.CreationCodeId = 0 OR e.CreationCodeId = 61)
ORDER BY e.EventDateTime ASC

GO
