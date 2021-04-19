SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the WidgetTemplateParameter table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateParameter_Find]
(

	@SearchUsingOR bit   = null ,

	@WidgetTemplateParameterId uniqueidentifier   = null ,

	@WidgetTemplateId uniqueidentifier   = null ,

	@NameId int   = null ,

	@Value varchar (MAX)  = null ,

	@Archived bit   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [WidgetTemplateParameterID]
	, [WidgetTemplateID]
	, [NameID]
	, [Value]
	, [Archived]
    FROM
	[dbo].[WidgetTemplateParameter]
    WHERE 
	 ([WidgetTemplateParameterID] = @WidgetTemplateParameterId OR @WidgetTemplateParameterId IS NULL)
	AND ([WidgetTemplateID] = @WidgetTemplateId OR @WidgetTemplateId IS NULL)
	AND ([NameID] = @NameId OR @NameId IS NULL)
	AND ([Value] = @Value OR @Value IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [WidgetTemplateParameterID]
	, [WidgetTemplateID]
	, [NameID]
	, [Value]
	, [Archived]
    FROM
	[dbo].[WidgetTemplateParameter]
    WHERE 
	 ([WidgetTemplateParameterID] = @WidgetTemplateParameterId AND @WidgetTemplateParameterId is not null)
	OR ([WidgetTemplateID] = @WidgetTemplateId AND @WidgetTemplateId is not null)
	OR ([NameID] = @NameId AND @NameId is not null)
	OR ([Value] = @Value AND @Value is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
