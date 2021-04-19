SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the GeofenceCategory table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GeofenceCategory_GetByGeofenceCategoryId]
(

	@GeofenceCategoryId int   
)
AS


				SELECT
					[GeofenceCategoryId],
					[Name],
					[Description],
					[Colour],
					[LastModified],
					[Archived]
				FROM
					[dbo].[GeofenceCategory]
				WHERE
					[GeofenceCategoryId] = @GeofenceCategoryId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
