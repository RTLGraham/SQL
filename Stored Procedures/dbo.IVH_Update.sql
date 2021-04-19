SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the IVH table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[IVH_Update]
(

	@IvhId uniqueidentifier   ,

	@IvhIntId int   ,

	@TrackerNumber varchar (50)  ,

	@Manufacturer varchar (50)  ,

	@Model varchar (50)  ,

	@PacketType varchar (50)  ,

	@PhoneNumber varchar (50)  ,

	@SimCardNumber varchar (50)  ,

	@ServiceProvider varchar (50)  ,

	@SerialNumber varchar (50)  ,

	@FirmwareVersion varchar (50)  ,

	@AntennaType varchar (50)  ,

	@LastOperation smalldatetime   ,

	@Archived bit   ,

	@IsTag bit   ,

	@IVHTypeId int   ,

	@isDev BIT = null
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[IVH]
				SET
					[TrackerNumber] = @TrackerNumber
					,[Manufacturer] = @Manufacturer
					,[Model] = @Model
					,[PacketType] = @PacketType
					,[PhoneNumber] = @PhoneNumber
					,[SIMCardNumber] = @SimCardNumber
					,[ServiceProvider] = @ServiceProvider
					,[SerialNumber] = @SerialNumber
					,[FirmwareVersion] = @FirmwareVersion
					,[AntennaType] = @AntennaType
					,[LastOperation] = @LastOperation
					,[Archived] = @Archived
					,[IsTag] = @IsTag
					,[IVHTypeId] = @IVHTypeId
					,[IsDev] = ISNULL(@isDev, 0)
				WHERE
[IVHId] = @IvhId 
				
			



GO
