SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the MessageVehicle table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageVehicle_Insert]
(

	@MessageId int   ,

	@VehicleId uniqueidentifier   ,

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


				
				INSERT INTO [dbo].[MessageVehicle]
					(
					[MessageId]
					,[VehicleId]
					,[UserId]
					,[CommandId]
					,[TimeSent]
					,[MessageStatusHardwareId]
					,[MessageStatusWetwareId]
					,[LastModified]
					,[Archived]
					,[HasBeenDeleted]
					)
				VALUES
					(
					@MessageId
					,@VehicleId
					,@UserId
					,@CommandId
					,@TimeSent
					,@MessageStatusHardwareId
					,@MessageStatusWetwareId
					,@LastModified
					,@Archived
					,@HasBeenDeleted
					)
				
									
							
			


GO
