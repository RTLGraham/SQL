SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the TZ_TimeZones table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TZ_TimeZones_Get_List]

AS


				
				SELECT
					[TimeZoneId],
					[TimeZoneName],
					[UtcOffset]
				FROM
					[dbo].[TZ_TimeZones]

				SELECT @@ROWCOUNT
			


GO
