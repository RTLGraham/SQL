SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the WidgetTemplate table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplate_GetByWidgetTypeId]
(

	@WidgetTypeId int   
)
AS


				SET ANSI_NULLS OFF
				
				SELECT
					[WidgetTemplateID],
					[WidgetTypeID],
					[Name],
					[ThumbnailRelativePath],
					[Archived]
				FROM
					[dbo].[WidgetTemplate]
				WHERE
                            [WidgetTypeID] = @WidgetTypeId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
