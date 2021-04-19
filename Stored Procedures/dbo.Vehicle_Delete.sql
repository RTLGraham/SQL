SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the Vehicle table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Vehicle_Delete]
(

	@VehicleId uniqueidentifier   
)
AS


                    UPDATE [dbo].[Vehicle]
                    SET Archived = 1
				WHERE
					[VehicleId] = @VehicleId
					
			


GO
