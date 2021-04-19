SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the TAN_NotificationType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_NotificationType_Update]
(

	@NotificationTypeId int   ,

	@OriginalNotificationTypeId int   ,

	@Name varchar (255)  ,

	@Description varchar (MAX)  ,

	@Archived bit   ,

	@LastOperation smalldatetime   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[TAN_NotificationType]
				SET
					[NotificationTypeId] = @NotificationTypeId
					,[Name] = @Name
					,[Description] = @Description
					,[Archived] = @Archived
					,[LastOperation] = @LastOperation
				WHERE
[NotificationTypeId] = @OriginalNotificationTypeId 
				
			


GO
