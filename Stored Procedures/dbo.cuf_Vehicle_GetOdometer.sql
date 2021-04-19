SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_GetOdometer]
(
	@vid UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER
)
AS	
	DECLARE @distmult FLOAT
	SET @distmult = Cast(dbo.[UserPref](@uid, 202) as float)
	
	SELECT v.VehicleId, vle.OdoGPS AS OdometerKM, vle.OdoGPS * @distmult AS OdometerUserUnitsOfMeasure
	FROM dbo.Vehicle v
	--INNER JOIN dbo.VehicleLatestOdometer vlo ON vlo.VehicleId = v.VehicleId
	INNER JOIN dbo.VehicleLatestAllEvent vle ON vle.VehicleId = v.VehicleId
	WHERE v.VehicleId = @vid
GO
