SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the MessageVehicle table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageVehicle_Delete]
(

	@MessageId int   ,

	@VehicleId uniqueidentifier   
)
AS


                    UPDATE [dbo].[MessageVehicle]
                    SET Archived = 1
				WHERE
					[MessageId] = @MessageId
					AND [VehicleId] = @VehicleId
					
			


GO
