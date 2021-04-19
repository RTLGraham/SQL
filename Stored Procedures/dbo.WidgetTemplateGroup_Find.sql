SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the WidgetTemplateGroup table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateGroup_Find]
(

	@SearchUsingOR bit   = null ,

	@GroupId uniqueidentifier   = null ,

	@WidgetTemplateId uniqueidentifier   = null ,

	@Archived bit   = null ,

	@LastModified datetime   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [GroupId]
	, [WidgetTemplateId]
	, [Archived]
	, [LastModified]
    FROM
	[dbo].[WidgetTemplateGroup]
    WHERE 
	 ([GroupId] = @GroupId OR @GroupId IS NULL)
	AND ([WidgetTemplateId] = @WidgetTemplateId OR @WidgetTemplateId IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([LastModified] = @LastModified OR @LastModified IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [GroupId]
	, [WidgetTemplateId]
	, [Archived]
	, [LastModified]
    FROM
	[dbo].[WidgetTemplateGroup]
    WHERE 
	 ([GroupId] = @GroupId AND @GroupId is not null)
	OR ([WidgetTemplateId] = @WidgetTemplateId AND @WidgetTemplateId is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([LastModified] = @LastModified AND @LastModified is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
