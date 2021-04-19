SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the MessageHistory table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageHistory_Delete]
(

	@MessageId int   
)
AS


                    UPDATE [dbo].[MessageHistory]
                    SET Archived = 1
				WHERE
					[MessageId] = @MessageId
					
			


GO
