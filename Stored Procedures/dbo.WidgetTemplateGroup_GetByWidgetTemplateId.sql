SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the WidgetTemplateGroup table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateGroup_GetByWidgetTemplateId]
(

	@WidgetTemplateId uniqueidentifier   
)
AS


				SET ANSI_NULLS OFF
				
				SELECT
					[GroupId],
					[WidgetTemplateId],
					[Archived],
					[LastModified]
				FROM
					[dbo].[WidgetTemplateGroup]
				WHERE
                            [WidgetTemplateId] = @WidgetTemplateId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
