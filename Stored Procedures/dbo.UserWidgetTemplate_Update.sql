SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the UserWidgetTemplate table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserWidgetTemplate_Update]
(

	@UserId uniqueidentifier   ,

	@OriginalUserId uniqueidentifier   ,

	@WidgetTemplateId uniqueidentifier   ,

	@OriginalWidgetTemplateId uniqueidentifier   ,

	@Archived bit   ,

	@UsageCount int   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[UserWidgetTemplate]
				SET
					[UserID] = @UserId
					,[WidgetTemplateID] = @WidgetTemplateId
					,[Archived] = @Archived
					,[UsageCount] = @UsageCount
				WHERE
[UserID] = @OriginalUserId 
AND [WidgetTemplateID] = @OriginalWidgetTemplateId 
				
			


GO
