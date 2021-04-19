SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the CustomerPreference table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CustomerPreference_Find]
(

	@SearchUsingOR bit   = null ,

	@CustomerPreferenceId uniqueidentifier   = null ,

	@CustomerId uniqueidentifier   = null ,

	@NameId int   = null ,

	@Value nvarchar (MAX)  = null ,

	@Archived bit   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [CustomerPreferenceID]
	, [CustomerID]
	, [NameID]
	, [Value]
	, [Archived]
    FROM
	[dbo].[CustomerPreference]
    WHERE 
	 ([CustomerPreferenceID] = @CustomerPreferenceId OR @CustomerPreferenceId IS NULL)
	AND ([CustomerID] = @CustomerId OR @CustomerId IS NULL)
	AND ([NameID] = @NameId OR @NameId IS NULL)
	AND ([Value] = @Value OR @Value IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [CustomerPreferenceID]
	, [CustomerID]
	, [NameID]
	, [Value]
	, [Archived]
    FROM
	[dbo].[CustomerPreference]
    WHERE 
	 ([CustomerPreferenceID] = @CustomerPreferenceId AND @CustomerPreferenceId is not null)
	OR ([CustomerID] = @CustomerId AND @CustomerId is not null)
	OR ([NameID] = @NameId AND @NameId is not null)
	OR ([Value] = @Value AND @Value is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
