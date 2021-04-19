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


CREATE PROCEDURE [dbo].[GroupType_GetByGroupIdFromWidgetTemplateParameterGroup]
(

	@GroupId uniqueidentifier   
)
AS


SELECT dbo.[GroupType].[GroupTypeId]
       ,dbo.[GroupType].[GroupTypeName]
       ,dbo.[GroupType].[GroupTypeDescription]
  FROM dbo.[GroupType]
 WHERE EXISTS (SELECT 1
                 FROM dbo.[WidgetTemplateParameterGroup] 
                WHERE dbo.[WidgetTemplateParameterGroup].[GroupID] = @GroupId
                  )
				SELECT @@ROWCOUNT			
				


GO
