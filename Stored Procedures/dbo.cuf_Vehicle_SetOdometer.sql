SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_SetOdometer]
(
	@vid UNIQUEIDENTIFIER,
	@OdometerKM INT
)
AS	
	--DECLARE @vid UNIQUEIDENTIFIER,
	--		@Odometer INT
	--SET @vid = N'A3EF2554-D638-477C-87BF-85130A1F2AD2'
	--SET @Odometer = 15

	IF ISNULL(@OdometerKM, 0) > 0 AND @vid IS NOT NULL
		BEGIN	
			MERGE dbo.VehicleLatestOdometer AS target
			USING (SELECT VehicleId, CAST(@OdometerKM AS INT) AS Odo FROM Vehicle WHERE VehicleId = @vid) AS source	
			ON (target.VehicleId = source.VehicleId)
			WHEN MATCHED THEN
				UPDATE SET OdoGPS = source.Odo
			WHEN NOT MATCHED THEN	
				INSERT (VehicleId, OdoGPS, EventDateTime, LastOperation, Archived)
				VALUES (source.VehicleId, source.Odo, GETUTCDATE(), GETDATE(), 0);

			-- If an Odometer Offset is present remove it as it will no longer apply
			DELETE
            FROM dbo.VehicleOdoOffset
			FROM dbo.VehicleOdoOffset voo
			INNER JOIN dbo.Vehicle v ON v.VehicleIntId = voo.VehicleIntId
			WHERE v.VehicleId = @vid
			  AND v.Archived = 0
		END	
	ELSE 
		BEGIN
			RAISERROR('Odometer must be greated than 0, vehicle must be specified', 20, -1) WITH LOG 	
		END


GO
