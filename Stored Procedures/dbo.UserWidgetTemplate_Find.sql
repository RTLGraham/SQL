SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the UserWidgetTemplate table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserWidgetTemplate_Find]
(

	@SearchUsingOR bit   = null ,

	@UserId uniqueidentifier   = null ,

	@WidgetTemplateId uniqueidentifier   = null ,

	@Archived bit   = null ,

	@UsageCount int   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [UserID]
	, [WidgetTemplateID]
	, [Archived]
	, [UsageCount]
    FROM
	[dbo].[UserWidgetTemplate]
    WHERE 
	 ([UserID] = @UserId OR @UserId IS NULL)
	AND ([WidgetTemplateID] = @WidgetTemplateId OR @WidgetTemplateId IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([UsageCount] = @UsageCount OR @UsageCount IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [UserID]
	, [WidgetTemplateID]
	, [Archived]
	, [UsageCount]
    FROM
	[dbo].[UserWidgetTemplate]
    WHERE 
	 ([UserID] = @UserId AND @UserId is not null)
	OR ([WidgetTemplateID] = @WidgetTemplateId AND @WidgetTemplateId is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([UsageCount] = @UsageCount AND @UsageCount is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
