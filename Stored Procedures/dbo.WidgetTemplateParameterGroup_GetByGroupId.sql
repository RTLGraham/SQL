SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the WidgetTemplateParameterGroup table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateParameterGroup_GetByGroupId]
(

	@GroupId uniqueidentifier   
)
AS


				SET ANSI_NULLS OFF
				
				SELECT
					[WidgetTemplateID],
					[GroupID],
					[GroupTypeID]
				FROM
					[dbo].[WidgetTemplateParameterGroup]
				WHERE
                            [GroupID] = @GroupId
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
