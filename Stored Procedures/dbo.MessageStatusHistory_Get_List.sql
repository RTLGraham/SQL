SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the MessageStatusHistory table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageStatusHistory_Get_List]

AS


				
				SELECT
					[MessageStatusHistoryId],
					[MessageId],
					[MessageStatusId],
					[LastModified]
				FROM
					[dbo].[MessageStatusHistory]

				SELECT @@ROWCOUNT
			


GO
