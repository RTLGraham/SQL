SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Vehicle_LinkDriver]
(
	@vehicleId UNIQUEIDENTIFIER,
	@driverId UNIQUEIDENTIFIER = NULL
)
AS
BEGIN

	--Unassign currently linked driver
	UPDATE	dbo.VehicleDriver
	SET		Archived = 1, 
			EndDate = GETDATE(),
			LastOperation = GETDATE()
	WHERE	VehicleId = @vehicleId
			AND Archived = 0
			AND EndDate IS NULL
			
	IF @driverId IS NOT NULL
	BEGIN
		--Assign new driver
		INSERT INTO dbo.VehicleDriver
		        ( VehicleId ,
		          DriverId ,
		          StartDate ,
		          EndDate ,
		          LastOperation ,
		          Archived
		        )
		VALUES  ( @vehicleId ,	-- VehicleId - uniqueidentifier
		          @driverId ,	-- DriverId - uniqueidentifier
		          GETDATE() ,	-- StartDate - datetime
		          NULL ,		-- EndDate - datetime
		          GETDATE() ,	-- LastOperation - smalldatetime
		          0				-- Archived - bit
		        )
	END
	ELSE BEGIN
		UPDATE dbo.VehicleLatestEvent
		SET DriverId = NULL
		WHERE VehicleId = @vehicleId
	END
	
END

GO
