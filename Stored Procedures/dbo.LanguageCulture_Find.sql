SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the LanguageCulture table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[LanguageCulture_Find]
(

	@SearchUsingOR bit   = null ,

	@LanguageCultureId smallint   = null ,

	@Name nvarchar (255)  = null ,

	@Code nvarchar (20)  = null ,

	@Description nvarchar (MAX)  = null ,

	@HardwareIndex smallint   = null ,

	@Archived bit   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [LanguageCultureID]
	, [Name]
	, [Code]
	, [Description]
	, [HardwareIndex]
	, [Archived]
    FROM
	[dbo].[LanguageCulture]
    WHERE 
	 ([LanguageCultureID] = @LanguageCultureId OR @LanguageCultureId IS NULL)
	AND ([Name] = @Name OR @Name IS NULL)
	AND ([Code] = @Code OR @Code IS NULL)
	AND ([Description] = @Description OR @Description IS NULL)
	AND ([HardwareIndex] = @HardwareIndex OR @HardwareIndex IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [LanguageCultureID]
	, [Name]
	, [Code]
	, [Description]
	, [HardwareIndex]
	, [Archived]
    FROM
	[dbo].[LanguageCulture]
    WHERE 
	 ([LanguageCultureID] = @LanguageCultureId AND @LanguageCultureId is not null)
	OR ([Name] = @Name AND @Name is not null)
	OR ([Code] = @Code AND @Code is not null)
	OR ([Description] = @Description AND @Description is not null)
	OR ([HardwareIndex] = @HardwareIndex AND @HardwareIndex is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
