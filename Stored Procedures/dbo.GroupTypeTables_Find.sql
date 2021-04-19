SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the GroupTypeTables table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GroupTypeTables_Find]
(

	@SearchUsingOR bit   = null ,

	@GroupTypeId int   = null ,

	@EntityTableName nvarchar (255)  = null ,

	@EntityTablePrimaryKey nvarchar (255)  = null ,

	@EntityProc nvarchar (255)  = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [GroupTypeId]
	, [EntityTableName]
	, [EntityTablePrimaryKey]
	, [EntityProc]
    FROM
	[dbo].[GroupTypeTables]
    WHERE 
	 ([GroupTypeId] = @GroupTypeId OR @GroupTypeId IS NULL)
	AND ([EntityTableName] = @EntityTableName OR @EntityTableName IS NULL)
	AND ([EntityTablePrimaryKey] = @EntityTablePrimaryKey OR @EntityTablePrimaryKey IS NULL)
	AND ([EntityProc] = @EntityProc OR @EntityProc IS NULL)
						
  END
  ELSE
  BEGIN
    SELECT
	  [GroupTypeId]
	, [EntityTableName]
	, [EntityTablePrimaryKey]
	, [EntityProc]
    FROM
	[dbo].[GroupTypeTables]
    WHERE 
	 ([GroupTypeId] = @GroupTypeId AND @GroupTypeId is not null)
	OR ([EntityTableName] = @EntityTableName AND @EntityTableName is not null)
	OR ([EntityTablePrimaryKey] = @EntityTablePrimaryKey AND @EntityTablePrimaryKey is not null)
	OR ([EntityProc] = @EntityProc AND @EntityProc is not null)
	SELECT @@ROWCOUNT			
  END
				


GO
