SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the AnalogIoAlertType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[AnalogIoAlertType_Delete]
(

	@AnalogIoAlertTypeId int   
)
AS


                    UPDATE [dbo].[AnalogIoAlertType]
                    SET Archived = 1
				WHERE
					[AnalogIoAlertTypeId] = @AnalogIoAlertTypeId
					
			


GO
