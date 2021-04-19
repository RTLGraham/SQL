SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the MessageStatusHistory table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageStatusHistory_GetByMessageId]
(

	@MessageId int   
)
AS


				SET ANSI_NULLS OFF
				
				SELECT
					[MessageStatusHistoryId],
					[MessageId],
					[MessageStatusId],
					[LastModified]
				FROM
					[dbo].[MessageStatusHistory]
				WHERE
                            [MessageId] = @MessageId
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
