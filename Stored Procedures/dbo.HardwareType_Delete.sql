SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the HardwareType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[HardwareType_Delete]
(

	@HardwareTypeId int   
)
AS


                    UPDATE [dbo].[HardwareType]
                    SET Archived = 1
				WHERE
					[HardwareTypeId] = @HardwareTypeId
					
			


GO
