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


CREATE PROCEDURE [dbo].[WKD_WorkStateType_GetByWorkStateTypeId]
(

	@WorkStateTypeId int   
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
					[WorkStateTypeId] = @WorkStateTypeId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
