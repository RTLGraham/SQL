SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_AdminCreateVehicleAndAddToGroup]
    (
		@cid UNIQUEIDENTIFIER,
		@gid UNIQUEIDENTIFIER = NULL,
				
		@TrackerNumber varchar(50),
		@Manufacturer varchar(50),
		@Model varchar(50),
		@ServiceProvider varchar(50),
		@SIMCardNumber varchar(50),
		@SerialNumber varchar(50),
		@FirmwareVersion varchar(50),
		@PhoneNumber varchar(50),
		
		@Registration nvarchar(20),
		@MakeModel varchar(100),
		@BodyManufacturer varchar(50),
		@BodyType varchar(50),
		@ChassisNumber varchar(50),
		@VehicleTypeID INT,
		
		@IsCAN BIT
    )
AS 
    BEGIN
        BEGIN TRAN
        DECLARE @vid UNIQUEIDENTIFIER,
				@ivhid UNIQUEIDENTIFIER,
				@count INT
		
		SET @ivhid = NULL
		--Is there a tracker number already in DB
		SELECT TOP 1 @ivhid = IVHId
		FROM dbo.IVH i
		WHERE i.TrackerNumber = @TrackerNumber
			AND i.Archived = 0
		ORDER BY LastOperation DESC
		
		IF @ivhid IS NOT NULL
		BEGIN 
			--Tracker Exists
			UPDATE dbo.IVH
			SET Manufacturer = @Manufacturer,
				Model = @Model,
				SIMCardNumber = @SIMCardNumber,
				ServiceProvider = @ServiceProvider,
				SerialNumber = @SerialNumber,
				FirmwareVersion = @FirmwareVersion,
				PhoneNumber = @PhoneNumber
			WHERE IVHId = @ivhid
			
			--Remove From stock
			UPDATE dbo.CustomerIVHStock
			SET EndDate = GETDATE(),
				Archived = 1,
				LastOperation = GETDATE()
			WHERE IVHId = @ivhid
			
			SELECT TOP 1 @vid = VehicleId
			FROM dbo.Vehicle
			WHERE IVHId = @ivhid
			ORDER BY LastOperation DESC
			
			IF @vid IS NOT NULL
			BEGIN
				--Vehicle exists
				UPDATE dbo.Vehicle
				SET 
					Registration = @Registration,
					MakeModel = @MakeModel,
					BodyManufacturer = @BodyManufacturer,
					BodyType = @BodyType,
					ChassisNumber = @ChassisNumber,
					VehicleTypeID = @VehicleTypeID,
					Archived = 0,
					LastOperation = GETDATE(),
					IsCAN = @IsCAN
				WHERE VehicleId = @vid
				
				SELECT @count = COUNT(*)
				FROM dbo.CustomerVehicle
				WHERE Archived = 0 AND EndDate IS NULL AND VehicleId = @vid
				
				IF @count > 0
				BEGIN	
					--Change customer
					UPDATE dbo.CustomerVehicle
					SET CustomerId = @cid 
					WHERE VehicleId = @vid AND Archived = 0 AND EndDate IS NULL
				END
				ELSE BEGIN
					--Assign to customer
					INSERT INTO dbo.CustomerVehicle
					        ( VehicleId ,
					          CustomerId ,
					          StartDate ,
					          EndDate ,
					          LastOperation ,
					          Archived
					        )
					VALUES  ( @vid , -- VehicleId - uniqueidentifier
					          @cid , -- CustomerId - uniqueidentifier
					          GETDATE() , -- StartDate - datetime
					          NULL , -- EndDate - datetime
					          GETDATE() , -- LastOperation - smalldatetime
					          0  -- Archived - bit
					        )
				END
				
				--Remove from all vehicle groups        
				DELETE FROM dbo.GroupDetail
				WHERE EntityDataId = @vid AND GroupTypeId = 1
			END
			ELSE BEGIN
				--New Vehicle
				SET @vid = NEWID()
				
				INSERT INTO dbo.Vehicle
				        ( VehicleId ,
				          IVHId ,
				          Registration ,
				          MakeModel ,
				          BodyManufacturer ,
				          BodyType ,
				          ChassisNumber ,
				          VehicleTypeID,
				          Archived ,
				          LastOperation ,
				          IsCAN
				        )
				VALUES  ( @vid ,
				          @ivhid ,
				          @Registration,
						  @MakeModel,
						  @BodyManufacturer,
						  @BodyType,
						  @ChassisNumber,
						  @VehicleTypeID,
						  0,
						  GETDATE(),
						  @IsCAN
				        )
				        
				INSERT INTO dbo.CustomerVehicle
				        ( VehicleId ,
				          CustomerId ,
				          StartDate ,
				          EndDate ,
				          LastOperation ,
				          Archived
				        )
				VALUES  ( @vid , -- VehicleId - uniqueidentifier
				          @cid , -- CustomerId - uniqueidentifier
				          GETDATE() , -- StartDate - datetime
				          NULL , -- EndDate - datetime
				          GETDATE() , -- LastOperation - smalldatetime
				          0  -- Archived - bit
				        )
			END
		END
		ELSE BEGIN
			IF @TrackerNumber IS NOT NULL AND @TrackerNumber != ''
			BEGIN
				--Brand New tracker
				SET @ivhid = NEWID()				
				INSERT INTO dbo.IVH
						( IVHId ,
						  TrackerNumber ,
						  Manufacturer ,
						  Model ,
						  SIMCardNumber ,
						  ServiceProvider ,
						  SerialNumber ,
						  FirmwareVersion ,
						  PhoneNumber,
						  LastOperation ,
						  Archived
						)
				VALUES  ( @ivhid,
						@TrackerNumber,
						@Manufacturer,
						@Model ,
						@SIMCardNumber ,
						@ServiceProvider ,
						@SerialNumber ,
						@FirmwareVersion ,
						@PhoneNumber ,
						GETDATE(),
						0
						)
			END

			SET @vid = NEWID()
			INSERT INTO dbo.Vehicle
			        ( VehicleId ,
			          IVHId ,
			          Registration ,
			          MakeModel ,
			          BodyManufacturer ,
			          BodyType ,
			          ChassisNumber ,
			          VehicleTypeID,
			          Archived ,
			          LastOperation ,
			          IsCAN
			        )
			VALUES  ( @vid ,
			          @ivhid ,
			          @Registration,
					  @MakeModel,
					  @BodyManufacturer,
					  @BodyType,
					  @ChassisNumber,
					  @VehicleTypeID,
					  0,
					  GETDATE(),
					  @IsCAN
			        )
			        
			INSERT INTO dbo.CustomerVehicle
			        ( VehicleId ,
			          CustomerId ,
			          StartDate ,
			          EndDate ,
			          LastOperation ,
			          Archived
			        )
			VALUES  ( @vid , -- VehicleId - uniqueidentifier
			          @cid , -- CustomerId - uniqueidentifier
			          GETDATE() , -- StartDate - datetime
			          NULL , -- EndDate - datetime
			          GETDATE() , -- LastOperation - smalldatetime
			          0  -- Archived - bit
			        )
        END
        
        
        
        IF @gid IS NOT NULL
        BEGIN    
			INSERT INTO dbo.GroupDetail
					( GroupId ,
					  GroupTypeId ,
					  EntityDataId
					)
			VALUES  ( @gid , -- GroupId - uniqueidentifier
					  1 , -- GroupTypeId - int
					  @vid  -- EntityDataId - uniqueidentifier
					)
        END    
        
        COMMIT TRAN
    END


GO
