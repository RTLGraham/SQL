SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the VehicleCommand table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleCommand_Insert]
(

	@IvhId uniqueidentifier   ,

	@Command binary (1024)  ,

	@ExpiryDate smalldatetime   ,

	@AcknowledgedDate smalldatetime   ,

	@LastOperation smalldatetime   ,

	@Archived bit   ,

	@CommandId int    OUTPUT
)
AS


				
				INSERT INTO [dbo].[VehicleCommand]
					(
					[IVHId]
					,[Command]
					,[ExpiryDate]
					,[AcknowledgedDate]
					,[LastOperation]
					,[Archived]
					)
				VALUES
					(
					@IvhId
					,@Command
					,@ExpiryDate
					,@AcknowledgedDate
					,@LastOperation
					,@Archived
					)
				
				-- Get the identity value
				SET @CommandId = SCOPE_IDENTITY()
									
							
			


GO
