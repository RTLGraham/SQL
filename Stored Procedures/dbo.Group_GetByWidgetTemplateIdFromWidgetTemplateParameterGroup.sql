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


CREATE PROCEDURE [dbo].[Group_GetByWidgetTemplateIdFromWidgetTemplateParameterGroup]
(

	@WidgetTemplateId uniqueidentifier   
)
AS


SELECT dbo.[Group].[GroupId]
       ,dbo.[Group].[GroupName]
       ,dbo.[Group].[GroupTypeId]
       ,dbo.[Group].[IsParameter]
       ,dbo.[Group].[Archived]
       ,dbo.[Group].[LastModified]
       ,dbo.[Group].[OriginalGroupId]
  FROM dbo.[Group]
 WHERE EXISTS (SELECT 1
                 FROM dbo.[WidgetTemplateParameterGroup] 
                WHERE dbo.[WidgetTemplateParameterGroup].[WidgetTemplateID] = @WidgetTemplateId
                  AND dbo.[WidgetTemplateParameterGroup].[GroupID] = dbo.[Group].[GroupId]
                  )
                AND Archived = 0
				SELECT @@ROWCOUNT			
				


GO
