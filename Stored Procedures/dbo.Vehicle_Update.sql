SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the Vehicle table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Vehicle_Update]
(

	@VehicleId uniqueidentifier   ,

	@VehicleIntId int   ,

	@IvhId uniqueidentifier   ,

	@Registration varchar (20)  ,

	@MakeModel varchar (100)  ,

	@BodyManufacturer varchar (50)  ,

	@BodyType varchar (50)  ,

	@ChassisNumber varchar (50)  ,

	@FleetNumber varchar (20)  ,

	@DisplayColour varchar (6)  ,

	@IconId int   ,

	@Identifier varchar (200)  ,

	@Archived bit   ,

	@LastOperation smalldatetime   ,

	@RopEnabled bit   ,

	@Notes varchar (6000)  ,

	@IsTrailer bit   ,

	@FuelMultiplier float   ,

	@VehicleTypeId int   ,

	@IsCan bit   ,

	@IsPrivate bit   ,

	@ClaimRate int   ,
	
	@FuelTypeId TINYINT	  ,
	
	@EngineSize INT ,
	
	@MaxPax INT
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[Vehicle]
				SET
					[IVHId] = @IvhId
					,[Registration] = @Registration
					,[MakeModel] = @MakeModel
					,[BodyManufacturer] = @BodyManufacturer
					,[BodyType] = @BodyType
					,[ChassisNumber] = @ChassisNumber
					,[FleetNumber] = @FleetNumber
					,[DisplayColour] = @DisplayColour
					,[IconId] = @IconId
					,[Identifier] = @Identifier
					,[Archived] = @Archived
					,[LastOperation] = @LastOperation
					,[ROPEnabled] = @RopEnabled
					,[Notes] = @Notes
					,[IsTrailer] = @IsTrailer
					,[FuelMultiplier] = @FuelMultiplier
					,[VehicleTypeID] = @VehicleTypeId
					,[IsCAN] = @IsCan
					,[IsPrivate] = @IsPrivate
					,[ClaimRate] = @ClaimRate
					,[FuelTypeId] = @FuelTypeId
					,[EngineSize] = @EngineSize
					,[MaxPax] = @MaxPax
				WHERE
[VehicleId] = @VehicleId

GO
