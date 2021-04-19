SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the TAN_RecipientNotification table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_RecipientNotification_GetByNotificationTemplateIdRecipientName]
(

	@NotificationTemplateId uniqueidentifier   ,

	@RecipientName varchar (200)  
)
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
				WHERE
					[NotificationTemplateId] = @NotificationTemplateId
					AND [RecipientName] = @RecipientName
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
