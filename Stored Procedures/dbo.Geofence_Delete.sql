SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the Geofence table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Geofence_Delete]
(

	@GeofenceSpatialId bigint   
)
AS


                    UPDATE [dbo].[Geofence]
                    SET Archived = 1
				WHERE
					[GeofenceSpatialId] = @GeofenceSpatialId
					
			


GO
