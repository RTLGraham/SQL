SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the MessageStatus table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageStatus_Delete]
(

	@MessageStatusId int   
)
AS


                    UPDATE [dbo].[MessageStatus]
                    SET Archived = 1
				WHERE
					[MessageStatusId] = @MessageStatusId
					
			


GO
