SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the UserWidgetTemplate table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserWidgetTemplate_Insert]
(

	@UserId uniqueidentifier   ,

	@WidgetTemplateId uniqueidentifier   ,

	@Archived bit   ,

	@UsageCount int   
)
AS


				
				INSERT INTO [dbo].[UserWidgetTemplate]
					(
					[UserID]
					,[WidgetTemplateID]
					,[Archived]
					,[UsageCount]
					)
				VALUES
					(
					@UserId
					,@WidgetTemplateId
					,@Archived
					,@UsageCount
					)
				
									
							
			


GO
