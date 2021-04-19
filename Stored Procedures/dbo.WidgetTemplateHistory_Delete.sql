SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the WidgetTemplateHistory table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateHistory_Delete]
(

	@WidgetTemplateHistoryId uniqueidentifier   
)
AS


                    UPDATE [dbo].[WidgetTemplateHistory]
                    SET Archived = 1
				WHERE
					[WidgetTemplateHistoryID] = @WidgetTemplateHistoryId
					
			


GO
