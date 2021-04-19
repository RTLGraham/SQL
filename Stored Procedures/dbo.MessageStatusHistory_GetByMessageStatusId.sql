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


CREATE PROCEDURE [dbo].[MessageStatusHistory_GetByMessageStatusId]
(

	@MessageStatusId int   
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
                            [MessageStatusId] = @MessageStatusId
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
