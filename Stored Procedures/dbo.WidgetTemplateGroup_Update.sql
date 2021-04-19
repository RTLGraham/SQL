SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the WidgetTemplateGroup table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateGroup_Update]
(

	@GroupId uniqueidentifier   ,

	@OriginalGroupId uniqueidentifier   ,

	@WidgetTemplateId uniqueidentifier   ,

	@OriginalWidgetTemplateId uniqueidentifier   ,

	@Archived bit   ,

	@LastModified datetime   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[WidgetTemplateGroup]
				SET
					[GroupId] = @GroupId
					,[WidgetTemplateId] = @WidgetTemplateId
					,[Archived] = @Archived
					,[LastModified] = @LastModified
				WHERE
[GroupId] = @OriginalGroupId 
AND [WidgetTemplateId] = @OriginalWidgetTemplateId 
				
			


GO
