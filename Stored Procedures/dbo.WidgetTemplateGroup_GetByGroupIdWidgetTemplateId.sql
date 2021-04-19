SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the WidgetTemplateGroup table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateGroup_GetByGroupIdWidgetTemplateId]
(

	@GroupId uniqueidentifier   ,

	@WidgetTemplateId uniqueidentifier   
)
AS


				SELECT
					[GroupId],
					[WidgetTemplateId],
					[Archived],
					[LastModified]
				FROM
					[dbo].[WidgetTemplateGroup]
				WHERE
					[GroupId] = @GroupId
					AND [WidgetTemplateId] = @WidgetTemplateId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
