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


CREATE PROCEDURE [dbo].[WidgetTemplate_GetByUserIdFromUserWidgetTemplate]
(

	@UserId uniqueidentifier   
)
AS


SELECT dbo.[WidgetTemplate].[WidgetTemplateID]
       ,dbo.[WidgetTemplate].[WidgetTypeID]
       ,dbo.[WidgetTemplate].[Name]
       ,dbo.[WidgetTemplate].[ThumbnailRelativePath]
       ,dbo.[WidgetTemplate].[Archived]
  FROM dbo.[WidgetTemplate]
 WHERE EXISTS (SELECT 1
                 FROM dbo.[UserWidgetTemplate] 
                WHERE dbo.[UserWidgetTemplate].[UserID] = @UserId
                  AND dbo.[UserWidgetTemplate].[WidgetTemplateID] = dbo.[WidgetTemplate].[WidgetTemplateID]
                  AND dbo.[UserWidgetTemplate].[Archived] = 0
                  )
                AND Archived = 0
				SELECT @@ROWCOUNT			
				


GO
