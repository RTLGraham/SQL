SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the MessageStatusHistory table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageStatusHistory_Delete]
(

	@MessageStatusHistoryId int   
)
AS


				    DELETE FROM [dbo].[MessageStatusHistory] WITH (ROWLOCK) 
				WHERE
					[MessageStatusHistoryId] = @MessageStatusHistoryId
					
			


GO
