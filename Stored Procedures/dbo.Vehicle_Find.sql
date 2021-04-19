SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the Vehicle table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Vehicle_Find]
(

	@SearchUsingOR bit   = null ,

	@VehicleId uniqueidentifier   = null ,

	@VehicleIntId int   = null ,

	@IvhId uniqueidentifier   = null ,

	@Registration varchar (20)  = null ,

	@MakeModel varchar (100)  = null ,

	@BodyManufacturer varchar (50)  = null ,

	@BodyType varchar (50)  = null ,

	@ChassisNumber varchar (50)  = null ,

	@FleetNumber varchar (20)  = null ,

	@DisplayColour varchar (6)  = null ,

	@IconId int   = null ,

	@Identifier varchar (200)  = null ,

	@Archived bit   = null ,

	@LastOperation smalldatetime   = null ,

	@RopEnabled bit   = null ,

	@Notes varchar (6000)  = null ,

	@IsTrailer bit   = null ,

	@FuelMultiplier float   = null ,

	@VehicleTypeId int   = null ,

	@IsCan bit   = null ,

	@IsPrivate bit   = null ,

	@ClaimRate int   = null ,
	
	@FuelTypeId TINYINT = NULL ,
	
	@EngineSize INT = NULL,
	
	@MaxPax INT = null
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [VehicleId]
	, [VehicleIntId]
	, [IVHId]
	, [Registration]
	, [MakeModel]
	, [BodyManufacturer]
	, [BodyType]
	, [ChassisNumber]
	, [FleetNumber]
	, [DisplayColour]
	, [IconId]
	, [Identifier]
	, [Archived]
	, [LastOperation]
	, [ROPEnabled]
	, [Notes]
	, [IsTrailer]
	, [FuelMultiplier]
	, [VehicleTypeID]
	, [IsCAN]
	, [IsPrivate]
	, [ClaimRate]
	, [FuelTypeId]
	, [EngineSize]
	, [MaxPax]
    FROM
	[dbo].[Vehicle]
    WHERE 
	 ([VehicleId] = @VehicleId OR @VehicleId IS NULL)
	AND ([VehicleIntId] = @VehicleIntId OR @VehicleIntId IS NULL)
	AND ([IVHId] = @IvhId OR @IvhId IS NULL)
	AND ([Registration] = @Registration OR @Registration IS NULL)
	AND ([MakeModel] = @MakeModel OR @MakeModel IS NULL)
	AND ([BodyManufacturer] = @BodyManufacturer OR @BodyManufacturer IS NULL)
	AND ([BodyType] = @BodyType OR @BodyType IS NULL)
	AND ([ChassisNumber] = @ChassisNumber OR @ChassisNumber IS NULL)
	AND ([FleetNumber] = @FleetNumber OR @FleetNumber IS NULL)
	AND ([DisplayColour] = @DisplayColour OR @DisplayColour IS NULL)
	AND ([IconId] = @IconId OR @IconId IS NULL)
	AND ([Identifier] = @Identifier OR @Identifier IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
	AND ([ROPEnabled] = @RopEnabled OR @RopEnabled IS NULL)
	AND ([Notes] = @Notes OR @Notes IS NULL)
	AND ([IsTrailer] = @IsTrailer OR @IsTrailer IS NULL)
	AND ([FuelMultiplier] = @FuelMultiplier OR @FuelMultiplier IS NULL)
	AND ([VehicleTypeID] = @VehicleTypeId OR @VehicleTypeId IS NULL)
	AND ([IsCAN] = @IsCan OR @IsCan IS NULL)
	AND ([IsPrivate] = @IsPrivate OR @IsPrivate IS NULL)
	AND ([ClaimRate] = @ClaimRate OR @ClaimRate IS NULL)
	AND ([FuelTypeId] = @FuelTypeId OR @FuelTypeId IS NULL)
	AND ([EngineSize] = @EngineSize OR @EngineSize IS NULL)
	AND ([MaxPax] = @MaxPax OR @MaxPax IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [VehicleId]
	, [VehicleIntId]
	, [IVHId]
	, [Registration]
	, [MakeModel]
	, [BodyManufacturer]
	, [BodyType]
	, [ChassisNumber]
	, [FleetNumber]
	, [DisplayColour]
	, [IconId]
	, [Identifier]
	, [Archived]
	, [LastOperation]
	, [ROPEnabled]
	, [Notes]
	, [IsTrailer]
	, [FuelMultiplier]
	, [VehicleTypeID]
	, [IsCAN]
	, [IsPrivate]
	, [ClaimRate]
	, [FuelTypeId]
	, [EngineSize]
	, [MaxPax]
    FROM
	[dbo].[Vehicle]
    WHERE 
	 ([VehicleId] = @VehicleId AND @VehicleId is not null)
	OR ([VehicleIntId] = @VehicleIntId AND @VehicleIntId is not null)
	OR ([IVHId] = @IvhId AND @IvhId is not null)
	OR ([Registration] = @Registration AND @Registration is not null)
	OR ([MakeModel] = @MakeModel AND @MakeModel is not null)
	OR ([BodyManufacturer] = @BodyManufacturer AND @BodyManufacturer is not null)
	OR ([BodyType] = @BodyType AND @BodyType is not null)
	OR ([ChassisNumber] = @ChassisNumber AND @ChassisNumber is not null)
	OR ([FleetNumber] = @FleetNumber AND @FleetNumber is not null)
	OR ([DisplayColour] = @DisplayColour AND @DisplayColour is not null)
	OR ([IconId] = @IconId AND @IconId is not null)
	OR ([Identifier] = @Identifier AND @Identifier is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	OR ([ROPEnabled] = @RopEnabled AND @RopEnabled is not null)
	OR ([Notes] = @Notes AND @Notes is not null)
	OR ([IsTrailer] = @IsTrailer AND @IsTrailer is not null)
	OR ([FuelMultiplier] = @FuelMultiplier AND @FuelMultiplier is not null)
	OR ([VehicleTypeID] = @VehicleTypeId AND @VehicleTypeId is not null)
	OR ([IsCAN] = @IsCan AND @IsCan is not null)
	OR ([IsPrivate] = @IsPrivate AND @IsPrivate is not null)
	OR ([ClaimRate] = @ClaimRate AND @ClaimRate is not null)
	OR ([FuelTypeId] = @FuelTypeId AND @FuelTypeId is not null)
	OR ([EngineSize] = @EngineSize AND @EngineSize is not null)
	OR ([MaxPax] = @MaxPax AND @MaxPax is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END

GO
