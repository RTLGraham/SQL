SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the GeofenceType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GeofenceType_Delete]
(

	@GeofenceTypeId int   
)
AS


                    UPDATE [dbo].[GeofenceType]
                    SET Archived = 1
				WHERE
					[GeofenceTypeId] = @GeofenceTypeId
					
			


GO
