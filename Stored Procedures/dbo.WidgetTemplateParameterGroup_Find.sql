SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the WidgetTemplateParameterGroup table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateParameterGroup_Find]
(

	@SearchUsingOR bit   = null ,

	@WidgetTemplateId uniqueidentifier   = null ,

	@GroupId uniqueidentifier   = null ,

	@GroupTypeId int   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [WidgetTemplateID]
	, [GroupID]
	, [GroupTypeID]
    FROM
	[dbo].[WidgetTemplateParameterGroup]
    WHERE 
	 ([WidgetTemplateID] = @WidgetTemplateId OR @WidgetTemplateId IS NULL)
	AND ([GroupID] = @GroupId OR @GroupId IS NULL)
	AND ([GroupTypeID] = @GroupTypeId OR @GroupTypeId IS NULL)
						
  END
  ELSE
  BEGIN
    SELECT
	  [WidgetTemplateID]
	, [GroupID]
	, [GroupTypeID]
    FROM
	[dbo].[WidgetTemplateParameterGroup]
    WHERE 
	 ([WidgetTemplateID] = @WidgetTemplateId AND @WidgetTemplateId is not null)
	OR ([GroupID] = @GroupId AND @GroupId is not null)
	OR ([GroupTypeID] = @GroupTypeId AND @GroupTypeId is not null)
	SELECT @@ROWCOUNT			
  END
				


GO
