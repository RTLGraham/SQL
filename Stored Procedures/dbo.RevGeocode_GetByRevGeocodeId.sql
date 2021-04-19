SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the RevGeocode table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[RevGeocode_GetByRevGeocodeId]
(

	@RevGeocodeId int   
)
AS


				SELECT
					[RevGeocodeId],
					[Long],
					[Lat],
					[Address],
					[Postcode],
					[Archived],
					[LatLongIdx]
				FROM
					[dbo].[RevGeocode]
				WHERE
					[RevGeocodeId] = @RevGeocodeId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
