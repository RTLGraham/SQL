SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the TZ_TimeZones table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TZ_TimeZones_Update]
(

	@TimeZoneId smallint   ,

	@OriginalTimeZoneId smallint   ,

	@TimeZoneName nchar (35)  ,

	@UtcOffset int   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[TZ_TimeZones]
				SET
					[TimeZoneId] = @TimeZoneId
					,[TimeZoneName] = @TimeZoneName
					,[UtcOffset] = @UtcOffset
				WHERE
[TimeZoneId] = @OriginalTimeZoneId 
				
			


GO
