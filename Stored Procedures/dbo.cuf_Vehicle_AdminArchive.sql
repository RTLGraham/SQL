SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_AdminArchive]
(
	@vehicleId UNIQUEIDENTIFIER
)
AS
BEGIN
	BEGIN TRAN
	DECLARE @ivh UNIQUEIDENTIFIER,
			@cid UNIQUEIDENTIFIER,
			@custId UNIQUEIDENTIFIER
	
	--Release IVH
	SELECT TOP 1 @ivh = IVHId 
	FROM dbo.Vehicle
	WHERE VehicleId = @vehicleId
	
	UPDATE dbo.CustomerIVHStock
	SET EndDate = NULL,
		Archived = 0,
		LastOperation = GETDATE()
	WHERE IVHId = @ivh

	--Release camera
	SELECT TOP 1 @cid = c.CameraId, @custId = cust.CustomerID
	FROM dbo.Vehicle v
		INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
		INNER JOIN dbo.Customer cust ON cust.CustomerId = cv.CustomerId
		INNER JOIN dbo.VehicleCamera vc ON vc.VehicleId = v.VehicleId
		INNER JOIN dbo.Camera c ON c.CameraId = vc.CameraId
	WHERE v.VehicleId = @vehicleId AND vc.Archived = 0 AND vc.EndDate IS NULL AND c.Archived = 0
	ORDER BY c.LastOperation DESC
    
	IF @cid IS NOT NULL AND @custId IS NOT NULL
	BEGIN
		UPDATE dbo.VehicleCamera
		SET Archived = 1, EndDate = GETDATE()
		WHERE VehicleId = @vehicleId AND CameraId = @cid

		--INSERT INTO dbo.CustomerCameraStock
		--        ( CustomerCameraStockId ,
		--          CameraId ,
		--          CustomerId ,
		--          StartDate ,
		--          EndDate ,
		--          LastOperation ,
		--          Archived
		--        )
		--VALUES  ( NEWID() , -- CustomerCameraStockId - uniqueidentifier
		--          @cid , -- CameraId - uniqueidentifier
		--          @custId , -- CustomerId - uniqueidentifier
		--          GETDATE() , -- StartDate - datetime
		--          NULL , -- EndDate - datetime
		--          GETDATE() , -- LastOperation - smalldatetime
		--          0  -- Archived - bit
		--        )
	END
	
	--Archive vehicle
	UPDATE dbo.Vehicle
	SET Archived = 1, IVHId = NULL
	WHERE VehicleId = @vehicleId
	
	--Archive Customer Vehicle
	UPDATE dbo.CustomerVehicle
	SET Archived = 1,
		EndDate = GETDATE()
	WHERE VehicleId = @vehicleId
	
	COMMIT TRAN
END


GO
