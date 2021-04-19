SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the GroupType table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GroupType_Find]
(

	@SearchUsingOR bit   = null ,

	@GroupTypeId int   = null ,

	@GroupTypeName nvarchar (255)  = null ,

	@GroupTypeDescription nvarchar (MAX)  = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [GroupTypeId]
	, [GroupTypeName]
	, [GroupTypeDescription]
    FROM
	[dbo].[GroupType]
    WHERE 
	 ([GroupTypeId] = @GroupTypeId OR @GroupTypeId IS NULL)
	AND ([GroupTypeName] = @GroupTypeName OR @GroupTypeName IS NULL)
	AND ([GroupTypeDescription] = @GroupTypeDescription OR @GroupTypeDescription IS NULL)
						
  END
  ELSE
  BEGIN
    SELECT
	  [GroupTypeId]
	, [GroupTypeName]
	, [GroupTypeDescription]
    FROM
	[dbo].[GroupType]
    WHERE 
	 ([GroupTypeId] = @GroupTypeId AND @GroupTypeId is not null)
	OR ([GroupTypeName] = @GroupTypeName AND @GroupTypeName is not null)
	OR ([GroupTypeDescription] = @GroupTypeDescription AND @GroupTypeDescription is not null)
	SELECT @@ROWCOUNT			
  END
				


GO
