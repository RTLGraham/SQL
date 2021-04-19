SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the WidgetTemplate table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplate_Find]
(

	@SearchUsingOR bit   = null ,

	@WidgetTemplateId uniqueidentifier   = null ,

	@WidgetTypeId int   = null ,

	@Name nvarchar (255)  = null ,

	@ThumbnailRelativePath nvarchar (MAX)  = null ,

	@Archived bit   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [WidgetTemplateID]
	, [WidgetTypeID]
	, [Name]
	, [ThumbnailRelativePath]
	, [Archived]
    FROM
	[dbo].[WidgetTemplate]
    WHERE 
	 ([WidgetTemplateID] = @WidgetTemplateId OR @WidgetTemplateId IS NULL)
	AND ([WidgetTypeID] = @WidgetTypeId OR @WidgetTypeId IS NULL)
	AND ([Name] = @Name OR @Name IS NULL)
	AND ([ThumbnailRelativePath] = @ThumbnailRelativePath OR @ThumbnailRelativePath IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [WidgetTemplateID]
	, [WidgetTypeID]
	, [Name]
	, [ThumbnailRelativePath]
	, [Archived]
    FROM
	[dbo].[WidgetTemplate]
    WHERE 
	 ([WidgetTemplateID] = @WidgetTemplateId AND @WidgetTemplateId is not null)
	OR ([WidgetTypeID] = @WidgetTypeId AND @WidgetTypeId is not null)
	OR ([Name] = @Name AND @Name is not null)
	OR ([ThumbnailRelativePath] = @ThumbnailRelativePath AND @ThumbnailRelativePath is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
