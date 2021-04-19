SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the WKD_WorkStateType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkStateType_Delete]
(

	@WorkStateTypeId int   
)
AS


                    UPDATE [dbo].[WKD_WorkStateType]
                    SET Archived = 1
				WHERE
					[WorkStateTypeId] = @WorkStateTypeId
					
			


GO
