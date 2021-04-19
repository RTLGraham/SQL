SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the WidgetTemplateGroup table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateGroup_Get_List]

AS


				
				SELECT
					[GroupId],
					[WidgetTemplateId],
					[Archived],
					[LastModified]
				FROM
					[dbo].[WidgetTemplateGroup]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
