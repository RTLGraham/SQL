SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the RevGeocode table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[RevGeocode_Get_List]

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
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
