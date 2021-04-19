SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the Group table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Group_Delete]
(

	@GroupId uniqueidentifier   
)
AS


                    UPDATE [dbo].[Group]
                    SET Archived = 1
				WHERE
					[GroupId] = @GroupId
					
			


GO
