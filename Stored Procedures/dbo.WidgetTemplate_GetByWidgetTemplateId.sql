SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the WidgetTemplate table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplate_GetByWidgetTemplateId]
(

	@WidgetTemplateId uniqueidentifier   
)
AS


				SELECT
					[WidgetTemplateID],
					[WidgetTypeID],
					[Name],
					[ThumbnailRelativePath],
					[Archived]
				FROM
					[dbo].[WidgetTemplate]
				WHERE
					[WidgetTemplateID] = @WidgetTemplateId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
