SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the CFG_History table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_History_Get_List]

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

				SELECT @@ROWCOUNT
			


GO
