SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the Driver table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Driver_Find]
(

	@SearchUsingOR bit   = null ,

	@DriverId uniqueidentifier   = null ,

	@DriverIntId int   = null ,

	@Number varchar (32)  = null ,

	@NumberAlternate varchar (32)  = null ,

	@NumberAlternate2 varchar (32)  = null ,

	@FirstName varchar (50)  = null ,

	@Surname varchar (50)  = null ,

	@MiddleNames varchar (250)  = null ,

	@LastOperation smalldatetime   = null ,

	@Archived bit   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [DriverId]
	, [DriverIntId]
	, [Number]
	, [NumberAlternate]
	, [NumberAlternate2]
	, [FirstName]
	, [Surname]
	, [MiddleNames]
	, [LastOperation]
	, [Archived]
    FROM
	[dbo].[Driver]
    WHERE 
	 ([DriverId] = @DriverId OR @DriverId IS NULL)
	AND ([DriverIntId] = @DriverIntId OR @DriverIntId IS NULL)
	AND ([Number] = @Number OR @Number IS NULL)
	AND ([NumberAlternate] = @NumberAlternate OR @NumberAlternate IS NULL)
	AND ([NumberAlternate2] = @NumberAlternate2 OR @NumberAlternate2 IS NULL)
	AND ([FirstName] = @FirstName OR @FirstName IS NULL)
	AND ([Surname] = @Surname OR @Surname IS NULL)
	AND ([MiddleNames] = @MiddleNames OR @MiddleNames IS NULL)
	AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [DriverId]
	, [DriverIntId]
	, [Number]
	, [NumberAlternate]
	, [NumberAlternate2]
	, [FirstName]
	, [Surname]
	, [MiddleNames]
	, [LastOperation]
	, [Archived]
    FROM
	[dbo].[Driver]
    WHERE 
	 ([DriverId] = @DriverId AND @DriverId is not null)
	OR ([DriverIntId] = @DriverIntId AND @DriverIntId is not null)
	OR ([Number] = @Number AND @Number is not null)
	OR ([NumberAlternate] = @NumberAlternate AND @NumberAlternate is not null)
	OR ([NumberAlternate2] = @NumberAlternate2 AND @NumberAlternate2 is not null)
	OR ([FirstName] = @FirstName AND @FirstName is not null)
	OR ([Surname] = @Surname AND @Surname is not null)
	OR ([MiddleNames] = @MiddleNames AND @MiddleNames is not null)
	OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
