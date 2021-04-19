SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the UserPreference table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserPreference_Find]
(

	@SearchUsingOR bit   = null ,

	@UserPreferenceId uniqueidentifier   = null ,

	@UserId uniqueidentifier   = null ,

	@NameId int   = null ,

	@Value nvarchar (MAX)  = null ,

	@Archived bit   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [UserPreferenceID]
	, [UserID]
	, [NameID]
	, [Value]
	, [Archived]
    FROM
	[dbo].[UserPreference]
    WHERE 
	 ([UserPreferenceID] = @UserPreferenceId OR @UserPreferenceId IS NULL)
	AND ([UserID] = @UserId OR @UserId IS NULL)
	AND ([NameID] = @NameId OR @NameId IS NULL)
	AND ([Value] = @Value OR @Value IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [UserPreferenceID]
	, [UserID]
	, [NameID]
	, [Value]
	, [Archived]
    FROM
	[dbo].[UserPreference]
    WHERE 
	 ([UserPreferenceID] = @UserPreferenceId AND @UserPreferenceId is not null)
	OR ([UserID] = @UserId AND @UserId is not null)
	OR ([NameID] = @NameId AND @NameId is not null)
	OR ([Value] = @Value AND @Value is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
