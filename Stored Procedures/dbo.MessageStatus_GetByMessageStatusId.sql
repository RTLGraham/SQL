SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the MessageStatus table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageStatus_GetByMessageStatusId]
(

	@MessageStatusId int   
)
AS


				SELECT
					[MessageStatusId],
					[Name],
					[Description],
					[Archived]
				FROM
					[dbo].[MessageStatus]
				WHERE
					[MessageStatusId] = @MessageStatusId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
