SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_UnitInfo_UpdateOnHeartbeat]
(
	@VehicleId nchar(10),
	@UnitTime NVARCHAR(20) = NULL,
	@EconoSpeed BIT = NULL,
	@SDcard BIT = NULL,
	@Firmware NCHAR(10) = NULL
)
AS
BEGIN
	
	UPDATE dbo.UnitInfo
	SET UnitTime =		CASE WHEN @UnitTime IS NULL		THEN UnitTime	ELSE @UnitTime END,
		EconoSpeed =	CASE WHEN @EconoSpeed IS NULL	THEN EconoSpeed ELSE @EconoSpeed END,
		SDcard =		CASE WHEN @SDcard IS NULL		THEN SDcard		ELSE @SDcard END,
		Firmware =		CASE WHEN @UnitTime IS NULL		THEN Firmware	ELSE @Firmware END
	WHERE VehicleId = @VehicleId
	
END




GO
