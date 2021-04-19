SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the WidgetTemplateHistory table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateHistory_Get_List]

AS


				
				SELECT
					[WidgetTemplateHistoryID],
					[WidgetTemplateID],
					[DateClosed],
					[UserID],
					[Archived]
				FROM
					[dbo].[WidgetTemplateHistory]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
