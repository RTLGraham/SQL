SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the TAN_NotificationTemplate table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_NotificationTemplate_Get_List]

AS


				
				SELECT
					[NotificationTemplateId],
					[TriggerId],
					[NotificationTypeId],
					[Header],
					[Body],
					[Disabled],
					[Archived],
					[LastOperation],
					[Count]
				FROM
					[dbo].[TAN_NotificationTemplate]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
