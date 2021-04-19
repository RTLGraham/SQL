SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the TAN_NotificationTemplate table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_NotificationTemplate_Update]
(

	@NotificationTemplateId uniqueidentifier   ,

	@OriginalNotificationTemplateId uniqueidentifier   ,

	@TriggerId uniqueidentifier   ,

	@NotificationTypeId int   ,

	@Header varchar (500)  ,

	@Body nvarchar (MAX)  ,

	@Disabled bit   ,

	@Archived bit   ,

	@LastOperation smalldatetime   ,

	@Count bigint   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[TAN_NotificationTemplate]
				SET
					[NotificationTemplateId] = @NotificationTemplateId
					,[TriggerId] = @TriggerId
					,[NotificationTypeId] = @NotificationTypeId
					,[Header] = @Header
					,[Body] = @Body
					,[Disabled] = @Disabled
					,[Archived] = @Archived
					,[LastOperation] = @LastOperation
					,[Count] = @Count
				WHERE
[NotificationTemplateId] = @NotificationTemplateId 
				
			


GO
