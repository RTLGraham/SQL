SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the TZ_TimeZones table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TZ_TimeZones_Insert]
(

	@TimeZoneId smallint   ,

	@TimeZoneName nchar (35)  ,

	@UtcOffset int   
)
AS


				
				INSERT INTO [dbo].[TZ_TimeZones]
					(
					[TimeZoneId]
					,[TimeZoneName]
					,[UtcOffset]
					)
				VALUES
					(
					@TimeZoneId
					,@TimeZoneName
					,@UtcOffset
					)
				
									
							
			


GO
