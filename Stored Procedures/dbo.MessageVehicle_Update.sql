SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the MessageVehicle table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageVehicle_Update]
(

	@MessageId int   ,

	@OriginalMessageId int   ,

	@VehicleId uniqueidentifier   ,

	@OriginalVehicleId uniqueidentifier   ,

	@UserId uniqueidentifier   ,

	@CommandId int   ,

	@TimeSent datetime   ,

	@MessageStatusHardwareId int   ,

	@MessageStatusWetwareId int   ,

	@LastModified datetime   ,

	@Archived bit   ,

	@HasBeenDeleted bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[MessageVehicle]
				SET
					[MessageId] = @MessageId
					,[VehicleId] = @VehicleId
					,[UserId] = @UserId
					,[CommandId] = @CommandId
					,[TimeSent] = @TimeSent
					,[MessageStatusHardwareId] = @MessageStatusHardwareId
					,[MessageStatusWetwareId] = @MessageStatusWetwareId
					,[LastModified] = @LastModified
					,[Archived] = @Archived
					,[HasBeenDeleted] = @HasBeenDeleted
				WHERE
[MessageId] = @OriginalMessageId 
AND [VehicleId] = @OriginalVehicleId 
				
			


GO
