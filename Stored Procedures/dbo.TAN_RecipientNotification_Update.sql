SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the TAN_RecipientNotification table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_RecipientNotification_Update]
(

	@NotificationTemplateId uniqueidentifier   ,

	@OriginalNotificationTemplateId uniqueidentifier   ,

	@RecipientName varchar (200)  ,

	@OriginalRecipientName varchar (200)  ,

	@RecipientAddress varchar (200)  ,

	@Disabled bit   ,

	@Archived bit   ,

	@LastOperation smalldatetime   ,

	@Count bigint   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[TAN_RecipientNotification]
				SET
					[NotificationTemplateId] = @NotificationTemplateId
					,[RecipientName] = @RecipientName
					,[RecipientAddress] = @RecipientAddress
					,[Disabled] = @Disabled
					,[Archived] = @Archived
					,[LastOperation] = @LastOperation
					,[Count] = @Count
				WHERE
[NotificationTemplateId] = @OriginalNotificationTemplateId 
AND [RecipientName] = @OriginalRecipientName 
				
			


GO
