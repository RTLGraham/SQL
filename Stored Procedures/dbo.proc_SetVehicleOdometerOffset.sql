SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_SetVehicleOdometerOffset]
	@vid UNIQUEIDENTIFIER,
	@odoOffset INT,
	@uid UNIQUEIDENTIFIER
AS

	--DECLARE @vid UNIQUEIDENTIFIER,
	--		@odoOffset INT, 
	--		@uid UNIQUEIDENTIFIER
	--SET @vid = N'BDB82EB2-693B-4911-901D-23A92C2AE40D'
	--SET @odoOffset = 1999
	--SET @uid = N'EBB1BF66-C20B-46B3-906C-18FA4910F8CC'

	DECLARE @distmult FLOAT,
			@floatoffset FLOAT
	SELECT @distmult = CAST(ISNULL(Value, 1) AS FLOAT)
	FROM dbo.UserPreference
	WHERE NameID = 202
	  AND UserID = @uid

	SET @floatoffset = @odoOffset -- do this to try and avoid rounding errors between reading and writing

	MERGE dbo.VehicleOdoOffset AS target
	USING (SELECT VehicleIntId, ROUND(CASE WHEN @distmult = 0.0006214 THEN @floatoffset / 1000 / @distmult ELSE @floatoffset END, 0) AS Odo FROM dbo.Vehicle WHERE VehicleId = @vid) AS source	
	ON (target.VehicleIntId = source.VehicleIntId)
	WHEN MATCHED THEN
		UPDATE SET target.OdometerOffset = source.Odo
	WHEN NOT MATCHED THEN	
		INSERT (VehicleIntId, OdometerOffset, LastOperation)
		VALUES (source.VehicleIntId, source.Odo, GETDATE());





GO
