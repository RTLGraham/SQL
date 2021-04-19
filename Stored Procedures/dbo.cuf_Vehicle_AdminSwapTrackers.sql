SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_AdminSwapTrackers]
(
	@vehicleId UNIQUEIDENTIFIER,
	@ivhnew UNIQUEIDENTIFIER
)
AS
BEGIN
	DECLARE @ivhold UNIQUEIDENTIFIER,
			@count INT,
			@cid UNIQUEIDENTIFIER
	
	SELECT TOP 1 @ivhold = IVHId FROM dbo.Vehicle WHERE VehicleId = @vehicleId ORDER BY LastOperation DESC
	
	--Assign new tracker
	UPDATE dbo.Vehicle
	SET IVHId = @ivhnew
	WHERE VehicleId = @vehicleId
	
	UPDATE dbo.CustomerIVHStock
	SET EndDate = GETDATE(), Archived = 1
	WHERE IVHId = @ivhnew
	
	--Unassign old tracker
	SELECT @count = COUNT(*) FROM dbo.CustomerIVHStock WHERE IVHId = @ivhold
	
	IF @count > 0
	BEGIN
		UPDATE dbo.CustomerIVHStock
		SET EndDate = NULL, Archived = 0
		WHERE IVHId = @ivhold
	END
	ELSE BEGIN
		SELECT @cid = CustomerId FROM dbo.CustomerVehicle WHERE VehicleId = @vehicleId
		INSERT INTO dbo.CustomerIVHStock( IVHId ,CustomerId ,StartDate ,EndDate ,LastOperation ,Archived)
		VALUES  ( @ivhold , -- IVHId - uniqueidentifier
		          @cid , -- CustomerId - uniqueidentifier
		          GETDATE() , -- StartDate - datetime
		          NULL , -- EndDate - datetime
		          GETDATE() , -- LastOperation - smalldatetime
		          0  -- Archived - bit
		        )
	END
	
END



GO
