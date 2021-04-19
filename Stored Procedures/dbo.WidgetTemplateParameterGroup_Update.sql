SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the WidgetTemplateParameterGroup table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateParameterGroup_Update]
(

	@WidgetTemplateId uniqueidentifier   ,

	@OriginalWidgetTemplateId uniqueidentifier   ,

	@GroupId uniqueidentifier   ,

	@OriginalGroupId uniqueidentifier   ,

	@GroupTypeId int   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[WidgetTemplateParameterGroup]
				SET
					[WidgetTemplateID] = @WidgetTemplateId
					,[GroupID] = @GroupId
					,[GroupTypeID] = @GroupTypeId
				WHERE
[WidgetTemplateID] = @OriginalWidgetTemplateId 
AND [GroupID] = @OriginalGroupId 
				
			


GO
