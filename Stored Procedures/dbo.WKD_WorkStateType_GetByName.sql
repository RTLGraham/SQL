SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the WKD_WorkStateType table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkStateType_GetByName]
(

	@Name varchar (50)  
)
AS


				SELECT
					[WorkStateTypeId],
					[Name],
					[Description],
					[LastModified],
					[Archived]
				FROM
					[dbo].[WKD_WorkStateType]
				WHERE
					[Name] = @Name
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
