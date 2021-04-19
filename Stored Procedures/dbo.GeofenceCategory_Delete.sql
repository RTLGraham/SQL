SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the GeofenceCategory table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GeofenceCategory_Delete]
(

	@GeofenceCategoryId int   
)
AS


                    UPDATE [dbo].[GeofenceCategory]
                    SET Archived = 1
				WHERE
					[GeofenceCategoryId] = @GeofenceCategoryId
					
			


GO
