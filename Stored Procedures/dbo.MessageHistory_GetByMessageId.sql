SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the MessageHistory table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageHistory_GetByMessageId]
(

	@MessageId int   
)
AS


				SELECT
					[MessageId],
					[MessageText],
					[Lat],
					[Long],
					[ReverseGeocode],
					[Date],
					[LastModified],
					[Archived]
				FROM
					[dbo].[MessageHistory]
				WHERE
					[MessageId] = @MessageId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
