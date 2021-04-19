SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the CFG_History table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_History_GetByHistoryId]
(

	@HistoryId int   
)
AS


				SELECT
					[HistoryId],
					[IVHIntId],
					[KeyId],
					[KeyValue],
					[StartDate],
					[EndDate],
					[Status],
					[LastOperation]
				FROM
					[dbo].[CFG_History]
				WHERE
					[HistoryId] = @HistoryId
				SELECT @@ROWCOUNT
					
			


GO
