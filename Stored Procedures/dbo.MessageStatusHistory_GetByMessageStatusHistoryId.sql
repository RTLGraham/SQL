SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the MessageStatusHistory table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageStatusHistory_GetByMessageStatusHistoryId]
(

	@MessageStatusHistoryId int   
)
AS


				SELECT
					[MessageStatusHistoryId],
					[MessageId],
					[MessageStatusId],
					[LastModified]
				FROM
					[dbo].[MessageStatusHistory]
				WHERE
					[MessageStatusHistoryId] = @MessageStatusHistoryId
				SELECT @@ROWCOUNT
					
			


GO
