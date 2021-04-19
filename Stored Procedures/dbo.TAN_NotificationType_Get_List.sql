SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the TAN_NotificationType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_NotificationType_Get_List]

AS


				
				SELECT
					[NotificationTypeId],
					[Name],
					[Description],
					[Archived],
					[LastOperation]
				FROM
					[dbo].[TAN_NotificationType]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
