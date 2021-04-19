SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- Stored Procedure

CREATE PROC [dbo].[proc_WriteCamera]
	@Project		VARCHAR(50), 
	@Serial			VARCHAR(50), 
	@LicensePlate	VARCHAR(50) = NULL, 
	@ApiId			VARCHAR(50) = NULL, 
	@vehicleId		UNIQUEIDENTIFIER = NULL OUTPUT,
	@cameraId		UNIQUEIDENTIFIER = NULL OUTPUT
AS
	--DECLARE @Project		VARCHAR(50), 
	--		@Serial			VARCHAR(50), 
	--		@LicensePlate	VARCHAR(50), 
	--		@ApiId			VARCHAR(50),
	--@vehicleId		UNIQUEIDENTIFIER,	@cameraId		UNIQUEIDENTIFIER

	DECLARE @camProject VARCHAR(50),
			@ProjectId INT

	-- Check that this camera already exists in the correct project
	SELECT @cameraId = cam.CameraId
	FROM dbo.Camera cam
	WHERE cam.Serial = @Serial
		AND cam.Archived = 0

	--IF @camProject IS NOT NULL AND @camProject != @Project
	IF @cameraId IS NOT NULL
	BEGIN
		-- Camera exists, so archive as necessary
		UPDATE dbo.Camera
		SET Archived = 1, LastOperation = GETDATE()

		WHERE CameraId = @cameraId

		UPDATE dbo.VehicleCamera
		SET EndDate = GETDATE(), Archived = 1, LastOperation = GETDATE()
		WHERE CameraId = @cameraId
	END


	-- Camera does not exist so create everything
	DECLARE @reg varchar(20),
			@customerid UNIQUEIDENTIFIER

	--SET @reg = 'CAMERA ' + @Serial
	SET @reg = @LicensePlate
	SET @vehicleId = NEWID()

	INSERT INTO dbo.Vehicle(VehicleId ,Registration ,Archived , VehicleTypeID, IsCAN, LastOperation)
	VALUES(@vehicleId, @reg, 0, 1500000, 0, GETDATE())

	INSERT INTO VehicleLatestEvent (VehicleId) VALUES (@vehicleId)

	SELECT TOP 1 @customerid = c.CustomerId
	FROM dbo.Customer c
	INNER JOIN dbo.Project p ON c.CustomerId = p.CustomerId
	WHERE p.Project = @Project
		AND c.Archived = 0
		AND p.Archived = 0


	INSERT INTO CustomerVehicle (CustomerId, VehicleId, StartDate, EndDate)
	SELECT c.CustomerId, @vehicleId, GETDATE(), NULL
	FROM dbo.Customer c
	INNER JOIN dbo.Project p ON c.CustomerId = p.CustomerId
	WHERE p.Project = @Project
		AND c.Archived = 0
		AND p.Archived = 0

	SET @cameraId = NEWID()

	INSERT INTO dbo.Camera
			( CameraId ,
				ProjectId ,
				Serial ,
				LicensePlate ,
				ApiId ,
				LastOperation ,
				Archived
			)
	SELECT @cameraId, ProjectId, @Serial, @LicensePlate, @ApiId, GETDATE(), 0
	FROM dbo.Project
	WHERE Project = @Project
		AND Archived = 0

	INSERT INTO dbo.VehicleCamera
			( VehicleCameraID,
				VehicleId ,
				CameraId ,
				StartDate ,
				EndDate ,
				LastOperation ,
				Archived
			)
	VALUES  ( NEWID() ,
		        @vehicleId , -- VehicleId - uniqueidentifier
				@cameraId , -- CameraId - uniqueidentifier
				GETDATE() , -- StartDate - datetime
				NULL , -- EndDate - datetime
				GETDATE() , -- LastOperation - smalldatetime
				0  -- Archived - bit
			)	  


	DECLARE @groupName NVARCHAR(250),
			@groupId UNIQUEIDENTIFIER,
			@adminUserId UNIQUEIDENTIFIER,
			@customerName NVARCHAR(200)

	SELECT TOP 1 @adminUserId = u.UserId, @customerName = c.Name
	FROM dbo.[User] u
		INNER JOIN dbo.Customer c ON u.CustomerID = c.CustomerId
		INNER JOIN dbo.UserPreference up ON up.UserID = u.UserID
	WHERE c.CustomerId = @customerid AND up.NameID = 1013 AND up.Archived = 0 AND up.Value = 1
		AND u.Archived = 0

	IF @adminUserId IS NOT NULL
	BEGIN      
		SET @groupName = @customerName + ' Cameras'

		SELECT TOP 1 @groupId = g.GroupId
		FROM dbo.[Group] g
		WHERE g.GroupName = @groupName
			AND g.Archived = 0 AND g.IsParameter = 0 AND g.GroupTypeId = 1

		IF @groupId IS NULL
		BEGIN
			SET @groupId = NEWID()
			INSERT INTO dbo.[Group]
				    ( GroupId ,
				        GroupName ,
				        GroupTypeId ,
				        IsParameter ,
				        Archived ,
				        LastModified
				    )
			VALUES  ( @groupId , -- GroupId - uniqueidentifier
				        @groupName , -- GroupName - nvarchar(255)
				        1 , -- GroupTypeId - int
				        0 , -- IsParameter - bit
				        0 , -- Archived - bit
				        GETDATE() -- LastModified - datetime
				    ) 
			INSERT INTO dbo.UserGroup
				    ( UserId ,
				        GroupId ,
				        Archived ,
				        LastModified
				    )
			VALUES  ( @adminUserId , -- UserId - uniqueidentifier
				        @groupId , -- GroupId - uniqueidentifier
				        0 , -- Archived - bit
				        GETDATE()  -- LastModified - datetime
				    )     
		END      

		INSERT INTO dbo.GroupDetail
			    ( GroupId ,
			        GroupTypeId ,
			        EntityDataId
			    )
		VALUES  ( @groupId , -- GroupId - uniqueidentifier
			        1 , -- GroupTypeId - int
			        @vehicleId  -- EntityDataId - uniqueidentifier
			    )
	END

GO
