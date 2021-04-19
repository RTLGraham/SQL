SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the TZ_TimeZones table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TZ_TimeZones_Find]
(

	@SearchUsingOR bit   = null ,

	@TimeZoneId smallint   = null ,

	@TimeZoneName nchar (35)  = null ,

	@UtcOffset int   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [TimeZoneId]
	, [TimeZoneName]
	, [UtcOffset]
    FROM
	[dbo].[TZ_TimeZones]
    WHERE 
	 ([TimeZoneId] = @TimeZoneId OR @TimeZoneId IS NULL)
	AND ([TimeZoneName] = @TimeZoneName OR @TimeZoneName IS NULL)
	AND ([UtcOffset] = @UtcOffset OR @UtcOffset IS NULL)
						
  END
  ELSE
  BEGIN
    SELECT
	  [TimeZoneId]
	, [TimeZoneName]
	, [UtcOffset]
    FROM
	[dbo].[TZ_TimeZones]
    WHERE 
	 ([TimeZoneId] = @TimeZoneId AND @TimeZoneId is not null)
	OR ([TimeZoneName] = @TimeZoneName AND @TimeZoneName is not null)
	OR ([UtcOffset] = @UtcOffset AND @UtcOffset is not null)
	SELECT @@ROWCOUNT			
  END
				


GO
