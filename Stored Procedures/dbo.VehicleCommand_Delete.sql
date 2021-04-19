SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the VehicleCommand table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleCommand_Delete]
(

	@CommandId int   
)
AS


                    UPDATE [dbo].[VehicleCommand]
                    SET Archived = 1
				WHERE
					[CommandId] = @CommandId
					
			


GO
