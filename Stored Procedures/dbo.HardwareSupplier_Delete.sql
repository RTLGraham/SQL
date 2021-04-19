SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the HardwareSupplier table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[HardwareSupplier_Delete]
(

	@HardwareSupplierId int   
)
AS


                    UPDATE [dbo].[HardwareSupplier]
                    SET Archived = 1
				WHERE
					[HardwareSupplierId] = @HardwareSupplierId
					
			


GO
