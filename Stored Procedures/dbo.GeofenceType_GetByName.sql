SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the GeofenceType table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GeofenceType_GetByName]
(

	@Name nvarchar (255)  
)
AS


				SELECT
					[GeofenceTypeId],
					[Name],
					[Description],
					[Archived]
				FROM
					[dbo].[GeofenceType]
				WHERE
					[Name] = @Name
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
