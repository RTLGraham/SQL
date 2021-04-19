SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the WidgetTemplateHistory table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateHistory_Find]
(

	@SearchUsingOR bit   = null ,

	@WidgetTemplateHistoryId uniqueidentifier   = null ,

	@WidgetTemplateId uniqueidentifier   = null ,

	@DateClosed datetime   = null ,

	@UserId uniqueidentifier   = null ,

	@Archived bit   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [WidgetTemplateHistoryID]
	, [WidgetTemplateID]
	, [DateClosed]
	, [UserID]
	, [Archived]
    FROM
	[dbo].[WidgetTemplateHistory]
    WHERE 
	 ([WidgetTemplateHistoryID] = @WidgetTemplateHistoryId OR @WidgetTemplateHistoryId IS NULL)
	AND ([WidgetTemplateID] = @WidgetTemplateId OR @WidgetTemplateId IS NULL)
	AND ([DateClosed] = @DateClosed OR @DateClosed IS NULL)
	AND ([UserID] = @UserId OR @UserId IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [WidgetTemplateHistoryID]
	, [WidgetTemplateID]
	, [DateClosed]
	, [UserID]
	, [Archived]
    FROM
	[dbo].[WidgetTemplateHistory]
    WHERE 
	 ([WidgetTemplateHistoryID] = @WidgetTemplateHistoryId AND @WidgetTemplateHistoryId is not null)
	OR ([WidgetTemplateID] = @WidgetTemplateId AND @WidgetTemplateId is not null)
	OR ([DateClosed] = @DateClosed AND @DateClosed is not null)
	OR ([UserID] = @UserId AND @UserId is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
