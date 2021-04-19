SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the RevGeocode table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[RevGeocode_Delete]
(

	@RevGeocodeId int   
)
AS


                    UPDATE [dbo].[RevGeocode]
                    SET Archived = 1
				WHERE
					[RevGeocodeId] = @RevGeocodeId
					
			


GO
