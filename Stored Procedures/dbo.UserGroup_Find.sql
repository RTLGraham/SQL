SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the UserGroup table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserGroup_Find]
(

	@SearchUsingOR bit   = null ,

	@UserId uniqueidentifier   = null ,

	@GroupId uniqueidentifier   = null ,

	@Archived bit   = null ,

	@LastModified datetime   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [UserId]
	, [GroupId]
	, [Archived]
	, [LastModified]
    FROM
	[dbo].[UserGroup]
    WHERE 
	 ([UserId] = @UserId OR @UserId IS NULL)
	AND ([GroupId] = @GroupId OR @GroupId IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([LastModified] = @LastModified OR @LastModified IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [UserId]
	, [GroupId]
	, [Archived]
	, [LastModified]
    FROM
	[dbo].[UserGroup]
    WHERE 
	 ([UserId] = @UserId AND @UserId is not null)
	OR ([GroupId] = @GroupId AND @GroupId is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([LastModified] = @LastModified AND @LastModified is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
