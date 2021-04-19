SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the WidgetTemplateGroup table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateGroup_Delete]
(

	@GroupId uniqueidentifier   ,

	@WidgetTemplateId uniqueidentifier   
)
AS


                    UPDATE [dbo].[WidgetTemplateGroup]
                    SET Archived = 1
				WHERE
					[GroupId] = @GroupId
					AND [WidgetTemplateId] = @WidgetTemplateId
					
			


GO
