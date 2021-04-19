SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the TAN_NotificationTemplate table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_NotificationTemplate_Insert]
(

	@NotificationTemplateId uniqueidentifier   ,

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


				
				INSERT INTO [dbo].[TAN_NotificationTemplate]
					(
					[NotificationTemplateId]
					,[TriggerId]
					,[NotificationTypeId]
					,[Header]
					,[Body]
					,[Disabled]
					,[Archived]
					,[LastOperation]
					,[Count]
					)
				VALUES
					(
					@NotificationTemplateId
					,@TriggerId
					,@NotificationTypeId
					,@Header
					,@Body
					,@Disabled
					,@Archived
					,@LastOperation
					,@Count
					)
				
									
							
			


GO
