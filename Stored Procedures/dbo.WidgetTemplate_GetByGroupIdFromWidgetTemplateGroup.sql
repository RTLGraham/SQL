SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets records through a junction table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplate_GetByGroupIdFromWidgetTemplateGroup]
(

	@GroupId uniqueidentifier   
)
AS


SELECT dbo.[WidgetTemplate].[WidgetTemplateID]
       ,dbo.[WidgetTemplate].[WidgetTypeID]
       ,dbo.[WidgetTemplate].[Name]
       ,dbo.[WidgetTemplate].[ThumbnailRelativePath]
       ,dbo.[WidgetTemplate].[Archived]
  FROM dbo.[WidgetTemplate]
 WHERE EXISTS (SELECT 1
                 FROM dbo.[WidgetTemplateGroup] 
                WHERE dbo.[WidgetTemplateGroup].[GroupId] = @GroupId
                  AND dbo.[WidgetTemplateGroup].[WidgetTemplateId] = dbo.[WidgetTemplate].[WidgetTemplateID]
                  )
                AND Archived = 0
				SELECT @@ROWCOUNT			
				


GO
