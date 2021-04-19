SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the GroupDetail table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GroupDetail_Find]
(

	@SearchUsingOR bit   = null ,

	@GroupId uniqueidentifier   = null ,

	@GroupTypeId int   = null ,

	@EntityDataId uniqueidentifier   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [GroupId]
	, [GroupTypeId]
	, [EntityDataId]
    FROM
	[dbo].[GroupDetail]
    WHERE 
	 ([GroupId] = @GroupId OR @GroupId IS NULL)
	AND ([GroupTypeId] = @GroupTypeId OR @GroupTypeId IS NULL)
	AND ([EntityDataId] = @EntityDataId OR @EntityDataId IS NULL)
						
  END
  ELSE
  BEGIN
    SELECT
	  [GroupId]
	, [GroupTypeId]
	, [EntityDataId]
    FROM
	[dbo].[GroupDetail]
    WHERE 
	 ([GroupId] = @GroupId AND @GroupId is not null)
	OR ([GroupTypeId] = @GroupTypeId AND @GroupTypeId is not null)
	OR ([EntityDataId] = @EntityDataId AND @EntityDataId is not null)
	SELECT @@ROWCOUNT			
  END
				


GO
