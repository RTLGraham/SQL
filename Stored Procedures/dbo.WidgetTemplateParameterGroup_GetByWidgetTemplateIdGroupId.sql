SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the WidgetTemplateParameterGroup table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateParameterGroup_GetByWidgetTemplateIdGroupId]
(

	@WidgetTemplateId uniqueidentifier   ,

	@GroupId uniqueidentifier   
)
AS


				SELECT
					[WidgetTemplateID],
					[GroupID],
					[GroupTypeID]
				FROM
					[dbo].[WidgetTemplateParameterGroup]
				WHERE
					[WidgetTemplateID] = @WidgetTemplateId
					AND [GroupID] = @GroupId
				SELECT @@ROWCOUNT
					
			


GO
