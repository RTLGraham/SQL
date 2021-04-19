SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the VehicleMode table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleMode_Delete]
(

	@VehicleModeId int   
)
AS


                    UPDATE [dbo].[VehicleMode]
                    SET Archived = 1
				WHERE
					[VehicleModeID] = @VehicleModeId
					
			


GO
