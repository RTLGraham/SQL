SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the Indicator table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Indicator_Find]
(

	@SearchUsingOR bit   = null ,

	@IndicatorId int   = null ,

	@Name varchar (100)  = null ,

	@Description varchar (MAX)  = null ,

	@Archived bit   = null ,

	@HighLow bit   = null ,

	@Parameter varchar (50)  = null ,

	@Type varchar (2)  = null ,

	@LastModified datetime   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [IndicatorId]
	, [Name]
	, [Description]
	, [Archived]
	, [HighLow]
	, [Parameter]
	, [Type]
	, [LastModified]
    FROM
	[dbo].[Indicator]
    WHERE 
	 ([IndicatorId] = @IndicatorId OR @IndicatorId IS NULL)
	AND ([Name] = @Name OR @Name IS NULL)
	AND ([Description] = @Description OR @Description IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([HighLow] = @HighLow OR @HighLow IS NULL)
	AND ([Parameter] = @Parameter OR @Parameter IS NULL)
	AND ([Type] = @Type OR @Type IS NULL)
	AND ([LastModified] = @LastModified OR @LastModified IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [IndicatorId]
	, [Name]
	, [Description]
	, [Archived]
	, [HighLow]
	, [Parameter]
	, [Type]
	, [LastModified]
    FROM
	[dbo].[Indicator]
    WHERE 
	 ([IndicatorId] = @IndicatorId AND @IndicatorId is not null)
	OR ([Name] = @Name AND @Name is not null)
	OR ([Description] = @Description AND @Description is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([HighLow] = @HighLow AND @HighLow is not null)
	OR ([Parameter] = @Parameter AND @Parameter is not null)
	OR ([Type] = @Type AND @Type is not null)
	OR ([LastModified] = @LastModified AND @LastModified is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
