SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_AdminUpdate]
(
	@vid UNIQUEIDENTIFIER,
	@ivhid UNIQUEIDENTIFIER,
	
	@Manufacturer varchar(50),
	@Model varchar(50),
	@ServiceProvider varchar(50),
	@SIMCardNumber varchar(50),
	@SerialNumber varchar(50),
	@FirmwareVersion varchar(50),
	@PhoneNumber varchar(50),
	@IVHTypeId int,
	@isDev BIT = NULL,
	
	@Registration nvarchar(20),
	@MakeModel varchar(100),
	@BodyManufacturer varchar(50),
	@BodyType varchar(50),
	@ChassisNumber varchar(50),
	@VehicleTypeID INT,
		
	@IsCAN BIT,
	@IsPrivate BIT,
	@ClaimRate INT,
	@FuelTypeId TINYINT,
	@EngineSize INT,
	@FleetNumber varchar(20),
	
	@MaxPax INT
)
AS
BEGIN
	BEGIN TRAN

	IF @ivhid IS NOT NULL
	BEGIN
		UPDATE dbo.IVH
		SET Manufacturer = @Manufacturer,
			Model = @Model,
			SIMCardNumber = @SIMCardNumber,
			ServiceProvider = @ServiceProvider,
			SerialNumber = @SerialNumber,
			FirmwareVersion = @FirmwareVersion,
			PhoneNumber = @PhoneNumber,
			LastOperation = GETDATE(),
			IVHTypeId = @IVHTypeId,
			IsDev = @isDev
		WHERE IVHId = @ivhid

		UPDATE    CustomerIVHStock
		SET       EndDate = GETDATE(),
				Archived = 1,
				LastOperation = GETDATE()
		WHERE     IVHId = @IVHid
		AND       Archived = 0;
	END


	UPDATE dbo.Vehicle
	SET 
        IVHId = ISNULL(@IVHId, IVHId),
		Registration = @Registration,
		MakeModel = @MakeModel,
		BodyManufacturer = @BodyManufacturer,
		BodyType = @BodyType,
		ChassisNumber = @ChassisNumber,
		VehicleTypeID = @VehicleTypeID,
		Archived = 0,
		LastOperation = GETDATE() ,
		IsCAN = @IsCAN,
		IsPrivate = @IsPrivate,
		ClaimRate = @ClaimRate,
		FuelTypeId = @FuelTypeId,
		EngineSize = @EngineSize,
		FleetNumber = @FleetNumber,
		MaxPax = @MaxPax
	WHERE VehicleId = @vid
	
	COMMIT TRAN
END

GO
