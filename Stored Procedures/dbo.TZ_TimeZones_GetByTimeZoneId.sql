SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the TZ_TimeZones table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TZ_TimeZones_GetByTimeZoneId]
(

	@TimeZoneId smallint   
)
AS


				SELECT
					[TimeZoneId],
					[TimeZoneName],
					[UtcOffset]
				FROM
					[dbo].[TZ_TimeZones]
				WHERE
					[TimeZoneId] = @TimeZoneId
				SELECT @@ROWCOUNT
					
			


GO
