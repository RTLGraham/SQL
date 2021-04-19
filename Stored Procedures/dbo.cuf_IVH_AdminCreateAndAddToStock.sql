SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_IVH_AdminCreateAndAddToStock]
    (
		@cid UNIQUEIDENTIFIER,
				
		@TrackerNumber varchar(50),
		@Manufacturer varchar(50),
		@Model varchar(50),
		@ServiceProvider varchar(50),
		@SIMCardNumber varchar(50),
		@SerialNumber varchar(50),
		@FirmwareVersion varchar(50),
		@PhoneNumber varchar(50),
		@IVHTypeId INT,
		@isDev BIT = NULL
    )
AS 
    BEGIN
        BEGIN TRAN
	
        DECLARE @ivhid UNIQUEIDENTIFIER,
				@cidTmp INT,
				@vidTmp UNIQUEIDENTIFIER
		
		SET @ivhid = NULL
                    SET @cidTmp = NULL
                    SET @vidTmp = NULL

		--Is there a tracker number already in DB
		SELECT TOP 1 @ivhid = IVHId
		FROM dbo.IVH i
		WHERE i.TrackerNumber = @TrackerNumber
			AND i.Archived = 0
		ORDER BY LastOperation DESC
		
		IF @ivhid IS NOT NULL
		BEGIN 
			--Tracker Exists
			--Check if this is an unassigned tracker
			SELECT TOP 1 @cidTmp = c.CustomerIntId, @vidTmp = v.VehicleId
			FROM dbo.IVH i
				INNER JOIN dbo.Vehicle v ON i.IVHId = v.IVHId
				INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
				INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
			WHERE i.IVHId = @ivhid
			ORDER BY cv.LastOperation DESC

			IF @cidTmp = 1
			BEGIN
				--unassigned tracker
				UPDATE dbo.Vehicle SET Archived = 1, IVHId = NULL WHERE VehicleId = @vidTmp
				UPDATE dbo.CustomerVehicle SET Archived = 1 WHERE VehicleId = @vidTmp
				
                                        UPDATE    IVH
                                        SET       Manufacturer = @Manufacturer,
											Model = @Model,
											SIMCardNumber = @SIMCardNumber,
											ServiceProvider = @ServiceProvider,
											SerialNumber = @SerialNumber,
											FirmwareVersion = @FirmwareVersion,
											PhoneNumber = @PhoneNumber,
											LastOperation = GETDATE(),
											Archived = 0,
											IVHTypeId = @IVHTypeId
                                        WHERE     IVHId = @ivhid;

				INSERT INTO dbo.CustomerIVHStock
			        ( IVHId ,
			          CustomerId ,
			          StartDate ,
			          EndDate ,
			          LastOperation ,
			          Archived
			        )
				VALUES  ( @ivhid , -- IVHId - uniqueidentifier
						  @cid , -- CustomerId - uniqueidentifier
						  GETDATE() , -- StartDate - datetime
						  NULL , -- EndDate - datetime
						  GETDATE() , -- LastOperation - smalldatetime
						  0  -- Archived - bit
						)		
			END
			ELSE IF @cidTmp IS NULL
			BEGIN
				--tracker is in stock?
				SELECT TOP 1 @cidTmp = c.CustomerIntId
				FROM dbo.IVH i
					INNER JOIN dbo.CustomerIVHStock s ON s.IVHId = i.IVHId
					INNER JOIN dbo.Customer c ON c.CustomerId = s.CustomerId
				WHERE i.IVHId = @ivhid AND s.Archived = 0
				ORDER BY s.LastOperation DESC
				IF @cidTmp IS NOT NULL
				BEGIN
					RAISERROR('This tracker is already in the customer stock.', 16, 1)
				END
				ELSE BEGIN
					--add to stock
					INSERT INTO dbo.CustomerIVHStock
							( IVHId ,
							  CustomerId ,
							  StartDate ,
							  EndDate ,
							  LastOperation ,
							  Archived
							)
					VALUES  ( @ivhid , -- IVHId - uniqueidentifier
							  @cid , -- CustomerId - uniqueidentifier
							  GETDATE() , -- StartDate - datetime
							  NULL , -- EndDate - datetime
							  GETDATE() , -- LastOperation - smalldatetime
							  0  -- Archived - bit
							)		
				END
			END
			ELSE BEGIN
				--Tracker Exists
				RAISERROR('This tracker already exists.', 16, 1)
			END
		END
		ELSE BEGIN
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
					  PhoneNumber ,
					  LastOperation ,
					  Archived,
					  IVHTypeId,
					  IsDev
					)
			VALUES  ( @ivhid,
					@TrackerNumber,
					@Manufacturer,
					@Model ,
					@SIMCardNumber ,
					@ServiceProvider ,
					@SerialNumber ,
					@FirmwareVersion ,
					@PhoneNumber,
					GETDATE(),
					0,
					@IVHTypeId,
					ISNULL(@isDev, 0)
					)
					
			INSERT INTO dbo.CustomerIVHStock
			        ( IVHId ,
			          CustomerId ,
			          StartDate ,
			          EndDate ,
			          LastOperation ,
			          Archived
			        )
			VALUES  ( @ivhid , -- IVHId - uniqueidentifier
			          @cid , -- CustomerId - uniqueidentifier
			          GETDATE() , -- StartDate - datetime
			          NULL , -- EndDate - datetime
			          GETDATE() , -- LastOperation - smalldatetime
			          0  -- Archived - bit
			        )					
        END
        
        COMMIT TRAN
    END




GO
