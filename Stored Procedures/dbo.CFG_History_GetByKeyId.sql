SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the CFG_History table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_History_GetByKeyId]
(

	@KeyId int   
)
AS


				SET ANSI_NULLS OFF
				
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
                            [KeyId] = @KeyId
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
