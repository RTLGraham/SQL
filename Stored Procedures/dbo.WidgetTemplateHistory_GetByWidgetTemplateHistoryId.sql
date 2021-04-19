SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the WidgetTemplateHistory table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateHistory_GetByWidgetTemplateHistoryId]
(

	@WidgetTemplateHistoryId uniqueidentifier   
)
AS


				SELECT
					[WidgetTemplateHistoryID],
					[WidgetTemplateID],
					[DateClosed],
					[UserID],
					[Archived]
				FROM
					[dbo].[WidgetTemplateHistory]
				WHERE
					[WidgetTemplateHistoryID] = @WidgetTemplateHistoryId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
