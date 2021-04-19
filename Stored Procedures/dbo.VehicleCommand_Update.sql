SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the VehicleCommand table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleCommand_Update]
(

	@IvhId uniqueidentifier   ,

	@Command binary (1024)  ,

	@ExpiryDate smalldatetime   ,

	@AcknowledgedDate smalldatetime   ,

	@LastOperation smalldatetime   ,

	@Archived bit   ,

	@CommandId int   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[VehicleCommand]
				SET
					[IVHId] = @IvhId
					,[Command] = @Command
					,[ExpiryDate] = @ExpiryDate
					,[AcknowledgedDate] = @AcknowledgedDate
					,[LastOperation] = @LastOperation
					,[Archived] = @Archived
				WHERE
[CommandId] = @CommandId 
				
			


GO
