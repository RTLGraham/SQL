SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the Driver table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Driver_Delete]
(

	@DriverId uniqueidentifier   
)
AS


                    UPDATE [dbo].[Driver]
                    SET Archived = 1
				WHERE
					[DriverId] = @DriverId
					
			


GO
