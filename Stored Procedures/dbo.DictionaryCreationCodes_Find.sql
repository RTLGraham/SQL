SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the DictionaryCreationCodes table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DictionaryCreationCodes_Find]
(

	@SearchUsingOR bit   = null ,

	@CreationCodeId smallint   = null ,

	@DictionaryNameId int   = null ,

	@DictionaryCreationCodeTypeId int   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [CreationCodeId]
	, [DictionaryNameId]
	, [DictionaryCreationCodeTypeId]
    FROM
	[dbo].[DictionaryCreationCodes]
    WHERE 
	 ([CreationCodeId] = @CreationCodeId OR @CreationCodeId IS NULL)
	AND ([DictionaryNameId] = @DictionaryNameId OR @DictionaryNameId IS NULL)
	AND ([DictionaryCreationCodeTypeId] = @DictionaryCreationCodeTypeId OR @DictionaryCreationCodeTypeId IS NULL)
						
  END
  ELSE
  BEGIN
    SELECT
	  [CreationCodeId]
	, [DictionaryNameId]
	, [DictionaryCreationCodeTypeId]
    FROM
	[dbo].[DictionaryCreationCodes]
    WHERE 
	 ([CreationCodeId] = @CreationCodeId AND @CreationCodeId is not null)
	OR ([DictionaryNameId] = @DictionaryNameId AND @DictionaryNameId is not null)
	OR ([DictionaryCreationCodeTypeId] = @DictionaryCreationCodeTypeId AND @DictionaryCreationCodeTypeId is not null)
	SELECT @@ROWCOUNT			
  END
				


GO
