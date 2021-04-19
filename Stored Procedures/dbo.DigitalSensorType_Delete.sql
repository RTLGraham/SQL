SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the DigitalSensorType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DigitalSensorType_Delete]
(

	@DigitalSensorTypeId smallint   
)
AS


                    UPDATE [dbo].[DigitalSensorType]
                    SET Archived = 1
				WHERE
					[DigitalSensorTypeId] = @DigitalSensorTypeId
					
			


GO
