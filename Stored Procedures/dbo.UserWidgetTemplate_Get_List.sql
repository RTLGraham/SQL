SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the UserWidgetTemplate table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserWidgetTemplate_Get_List]

AS


				
				SELECT
					[UserID],
					[WidgetTemplateID],
					[Archived],
					[UsageCount]
				FROM
					[dbo].[UserWidgetTemplate]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
