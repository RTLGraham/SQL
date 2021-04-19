SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the MessageStatus table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageStatus_Get_List]

AS


				
				SELECT
					[MessageStatusId],
					[Name],
					[Description],
					[Archived]
				FROM
					[dbo].[MessageStatus]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
