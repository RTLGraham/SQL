SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the WidgetTemplateHistory table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateHistory_Update]
(

	@WidgetTemplateHistoryId uniqueidentifier   ,

	@WidgetTemplateId uniqueidentifier   ,

	@DateClosed datetime   ,

	@UserId uniqueidentifier   ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[WidgetTemplateHistory]
				SET
					[WidgetTemplateID] = @WidgetTemplateId
					,[DateClosed] = @DateClosed
					,[UserID] = @UserId
					,[Archived] = @Archived
				WHERE
[WidgetTemplateHistoryID] = @WidgetTemplateHistoryId 
				
			


GO
