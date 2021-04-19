SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the TAN_RecipientNotification table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_RecipientNotification_Get_List]

AS


				
				SELECT
					[NotificationTemplateId],
					[RecipientName],
					[RecipientAddress],
					[Disabled],
					[Archived],
					[LastOperation],
					[Count]
				FROM
					[dbo].[TAN_RecipientNotification]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
