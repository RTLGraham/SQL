SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the RevGeocode table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[RevGeocode_Find]
(

	@SearchUsingOR bit   = null ,

	@RevGeocodeId int   = null ,

	@SafeNameLong float   = null ,

	@Lat float   = null ,

	@Address varchar (100)  = null ,

	@Postcode varchar (50)  = null ,

	@Archived bit   = null ,

	@LatLongIdx bigint   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [RevGeocodeId]
	, [Long]
	, [Lat]
	, [Address]
	, [Postcode]
	, [Archived]
	, [LatLongIdx]
    FROM
	[dbo].[RevGeocode]
    WHERE 
	 ([RevGeocodeId] = @RevGeocodeId OR @RevGeocodeId IS NULL)
	AND ([Long] = @SafeNameLong OR @SafeNameLong IS NULL)
	AND ([Lat] = @Lat OR @Lat IS NULL)
	AND ([Address] = @Address OR @Address IS NULL)
	AND ([Postcode] = @Postcode OR @Postcode IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([LatLongIdx] = @LatLongIdx OR @LatLongIdx IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [RevGeocodeId]
	, [Long]
	, [Lat]
	, [Address]
	, [Postcode]
	, [Archived]
	, [LatLongIdx]
    FROM
	[dbo].[RevGeocode]
    WHERE 
	 ([RevGeocodeId] = @RevGeocodeId AND @RevGeocodeId is not null)
	OR ([Long] = @SafeNameLong AND @SafeNameLong is not null)
	OR ([Lat] = @Lat AND @Lat is not null)
	OR ([Address] = @Address AND @Address is not null)
	OR ([Postcode] = @Postcode AND @Postcode is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([LatLongIdx] = @LatLongIdx AND @LatLongIdx is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
