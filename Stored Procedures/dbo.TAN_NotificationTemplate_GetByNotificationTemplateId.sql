SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the TAN_NotificationTemplate table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_NotificationTemplate_GetByNotificationTemplateId]
(

	@NotificationTemplateId uniqueidentifier   
)
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
				WHERE
					[NotificationTemplateId] = @NotificationTemplateId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
