SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the TAN_RecipientNotification table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_RecipientNotification_GetByNotificationTemplateId]
(

	@NotificationTemplateId uniqueidentifier   
)
AS


				SET ANSI_NULLS OFF
				
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
				WHERE
                            [NotificationTemplateId] = @NotificationTemplateId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
