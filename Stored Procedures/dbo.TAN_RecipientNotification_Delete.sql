SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the TAN_RecipientNotification table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_RecipientNotification_Delete]
(

	@NotificationTemplateId uniqueidentifier   ,

	@RecipientName varchar (200)  
)
AS


                    UPDATE [dbo].[TAN_RecipientNotification]
                    SET Archived = 1
				WHERE
					[NotificationTemplateId] = @NotificationTemplateId
					AND [RecipientName] = @RecipientName
					
			


GO
