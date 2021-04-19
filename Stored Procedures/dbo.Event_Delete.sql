SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the Event table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Event_Delete]
(

	@EventId bigint   
)
AS


                    UPDATE [dbo].[Event]
                    SET Archived = 1
				WHERE
					[EventId] = @EventId
					
			


GO
