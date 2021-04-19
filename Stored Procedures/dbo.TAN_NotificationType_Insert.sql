SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the TAN_NotificationType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_NotificationType_Insert]
(

	@NotificationTypeId int   ,

	@Name varchar (255)  ,

	@Description varchar (MAX)  ,

	@Archived bit   ,

	@LastOperation smalldatetime   
)
AS


				
				INSERT INTO [dbo].[TAN_NotificationType]
					(
					[NotificationTypeId]
					,[Name]
					,[Description]
					,[Archived]
					,[LastOperation]
					)
				VALUES
					(
					@NotificationTypeId
					,@Name
					,@Description
					,@Archived
					,@LastOperation
					)
				
									
							
			


GO
