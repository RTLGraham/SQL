SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the GeofenceCategory table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GeofenceCategory_Get_List]

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
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
