SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the IVH table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[IVH_Insert]
(

	@IvhId uniqueidentifier    OUTPUT,

	@IvhIntId int    OUTPUT,

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

	@isDev BIT = NULL
)
AS


				
				Declare @IdentityRowGuids table (IvhId uniqueidentifier	)
				INSERT INTO [dbo].[IVH]
					(
					[TrackerNumber]
					,[Manufacturer]
					,[Model]
					,[PacketType]
					,[PhoneNumber]
					,[SIMCardNumber]
					,[ServiceProvider]
					,[SerialNumber]
					,[FirmwareVersion]
					,[AntennaType]
					,[LastOperation]
					,[Archived]
					,[IsTag]
					,[IVHTypeId]
					,[IsDev]
					)
						OUTPUT INSERTED.IVHId INTO @IdentityRowGuids
					
				VALUES
					(
					@TrackerNumber
					,@Manufacturer
					,@Model
					,@PacketType
					,@PhoneNumber
					,@SimCardNumber
					,@ServiceProvider
					,@SerialNumber
					,@FirmwareVersion
					,@AntennaType
					,@LastOperation
					,@Archived
					,@IsTag
					,@IVHTypeId
					,ISNULL(@isDev, 0)
					)
				
				SELECT @IvhId=IvhId	 from @IdentityRowGuids
				-- Get the identity value
				SET @IvhIntId = SCOPE_IDENTITY()
									
							
			



GO
