SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_SPD_GetTripsForSpeeding]
AS
BEGIN
	UPDATE dbo.TS_SpeedingControl
	SET ProcessInd = 1
	WHERE ProcessInd = 0
	SELECT tsc.SpeedingControlID,
			tsc.VehicleIntId,
			ISNULL(v.VehicleTypeID, 2100000) AS VehicleType,
			tsc.DriverIntId,
			tsc.TSStartDate,
			tsc.TSEndDate,
			DATEDIFF(day, tsc.TSStartDate,tsc.TSEndDate)
	FROM dbo.TS_SpeedingControl tsc
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = tsc.VehicleIntId
	WHERE tsc.ProcessInd = 1 

END

GO
