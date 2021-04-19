SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the Vehicle table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Vehicle_Insert]
(

	@VehicleId uniqueidentifier    OUTPUT,

	@VehicleIntId int    OUTPUT,

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
	
	@FuelTypeId TINYINT   ,
	
	@EngineSize INT ,
	
	@MaxPax INT
)
AS


				
				Declare @IdentityRowGuids table (VehicleId uniqueidentifier	)
				INSERT INTO [dbo].[Vehicle]
					(
					[IVHId]
					,[Registration]
					,[MakeModel]
					,[BodyManufacturer]
					,[BodyType]
					,[ChassisNumber]
					,[FleetNumber]
					,[DisplayColour]
					,[IconId]
					,[Identifier]
					,[Archived]
					,[LastOperation]
					,[ROPEnabled]
					,[Notes]
					,[IsTrailer]
					,[FuelMultiplier]
					,[VehicleTypeID]
					,[IsCAN]
					,[IsPrivate]
					,[ClaimRate]
					,[FuelTypeId]
					,[EngineSize]
					,[MaxPax]
					)
						OUTPUT INSERTED.VehicleId INTO @IdentityRowGuids
					
				VALUES
					(
					@IvhId
					,@Registration
					,@MakeModel
					,@BodyManufacturer
					,@BodyType
					,@ChassisNumber
					,@FleetNumber
					,@DisplayColour
					,@IconId
					,@Identifier
					,@Archived
					,@LastOperation
					,@RopEnabled
					,@Notes
					,@IsTrailer
					,@FuelMultiplier
					,@VehicleTypeId
					,@IsCan
					,@IsPrivate
					,@ClaimRate
					,@FuelTypeId
					,@EngineSize
					,@MaxPax
					)
				
				SELECT @VehicleId=VehicleId	 from @IdentityRowGuids
				-- Get the identity value
				SET @VehicleIntId = SCOPE_IDENTITY()

GO
