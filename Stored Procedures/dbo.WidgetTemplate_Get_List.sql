SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the WidgetTemplate table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplate_Get_List]

AS


				
				SELECT
					[WidgetTemplateID],
					[WidgetTypeID],
					[Name],
					[ThumbnailRelativePath],
					[Archived]
				FROM
					[dbo].[WidgetTemplate]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
