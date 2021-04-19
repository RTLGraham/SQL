SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_WriteLatestDriver]
	@did uniqueidentifier, @vid uniqueidentifier
AS
-- Only call this proc from within proc_writeEventNonID_Temp unless you really think.
-- Only gets called now when we really want to update the
-- latest driver id descision about said update is made before calling.

	IF (SELECT VehicleId FROM VehicleLatestEvent WHERE VehicleId=@vid) IS NOT NULL
		UPDATE VehicleLatestEvent SET DriverId = @did WHERE VehicleId = @vid
	ELSE
		INSERT INTO VehicleLatestEvent (VehicleId, DriverId) VALUES (@vid, @did)


GO
