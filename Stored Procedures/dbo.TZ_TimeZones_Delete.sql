SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the TZ_TimeZones table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TZ_TimeZones_Delete]
(

	@TimeZoneId smallint   
)
AS


				    DELETE FROM [dbo].[TZ_TimeZones] WITH (ROWLOCK) 
				WHERE
					[TimeZoneId] = @TimeZoneId
					
			


GO
