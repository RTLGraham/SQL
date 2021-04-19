SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the GeofenceType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GeofenceType_Get_List]

AS


				
				SELECT
					[GeofenceTypeId],
					[Name],
					[Description],
					[Archived]
				FROM
					[dbo].[GeofenceType]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
