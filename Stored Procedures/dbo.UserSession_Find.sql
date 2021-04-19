SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the UserSession table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserSession_Find]
(

	@SearchUsingOR bit   = null ,

	@SessionId uniqueidentifier   = null ,

	@UserId uniqueidentifier   = null ,

	@IsLoggedIn bit   = null ,

	@LastOperation datetime   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [SessionID]
	, [UserID]
	, [IsLoggedIn]
	, [LastOperation]
    FROM
	[dbo].[UserSession]
    WHERE 
	 ([SessionID] = @SessionId OR @SessionId IS NULL)
	AND ([UserID] = @UserId OR @UserId IS NULL)
	AND ([IsLoggedIn] = @IsLoggedIn OR @IsLoggedIn IS NULL)
	AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
						
  END
  ELSE
  BEGIN
    SELECT
	  [SessionID]
	, [UserID]
	, [IsLoggedIn]
	, [LastOperation]
    FROM
	[dbo].[UserSession]
    WHERE 
	 ([SessionID] = @SessionId AND @SessionId is not null)
	OR ([UserID] = @UserId AND @UserId is not null)
	OR ([IsLoggedIn] = @IsLoggedIn AND @IsLoggedIn is not null)
	OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	SELECT @@ROWCOUNT			
  END
				


GO
