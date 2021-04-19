SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the Group table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Group_Find]
(

	@SearchUsingOR bit   = null ,

	@GroupId uniqueidentifier   = null ,

	@GroupName nvarchar (255)  = null ,

	@GroupTypeId int   = null ,

	@IsParameter bit   = null ,

	@Archived bit   = null ,

	@LastModified datetime   = null ,

	@OriginalGroupId uniqueidentifier   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [GroupId]
	, [GroupName]
	, [GroupTypeId]
	, [IsParameter]
	, [Archived]
	, [LastModified]
	, [OriginalGroupId]
    FROM
	[dbo].[Group]
    WHERE 
	 ([GroupId] = @GroupId OR @GroupId IS NULL)
	AND ([GroupName] = @GroupName OR @GroupName IS NULL)
	AND ([GroupTypeId] = @GroupTypeId OR @GroupTypeId IS NULL)
	AND ([IsParameter] = @IsParameter OR @IsParameter IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([LastModified] = @LastModified OR @LastModified IS NULL)
	AND ([OriginalGroupId] = @OriginalGroupId OR @OriginalGroupId IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [GroupId]
	, [GroupName]
	, [GroupTypeId]
	, [IsParameter]
	, [Archived]
	, [LastModified]
	, [OriginalGroupId]
    FROM
	[dbo].[Group]
    WHERE 
	 ([GroupId] = @GroupId AND @GroupId is not null)
	OR ([GroupName] = @GroupName AND @GroupName is not null)
	OR ([GroupTypeId] = @GroupTypeId AND @GroupTypeId is not null)
	OR ([IsParameter] = @IsParameter AND @IsParameter is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([LastModified] = @LastModified AND @LastModified is not null)
	OR ([OriginalGroupId] = @OriginalGroupId AND @OriginalGroupId is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
