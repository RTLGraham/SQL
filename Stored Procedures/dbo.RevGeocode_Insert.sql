SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the RevGeocode table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[RevGeocode_Insert]
(

	@RevGeocodeId int    OUTPUT,

	@SafeNameLong float   ,

	@Lat float   ,

	@Address varchar (100)  ,

	@Postcode varchar (50)  ,

	@Archived bit   ,

	@LatLongIdx bigint   
)
AS


				
				INSERT INTO [dbo].[RevGeocode]
					(
					[Long]
					,[Lat]
					,[Address]
					,[Postcode]
					,[Archived]
					,[LatLongIdx]
					)
				VALUES
					(
					@SafeNameLong
					,@Lat
					,@Address
					,@Postcode
					,@Archived
					,@LatLongIdx
					)
				
				-- Get the identity value
				SET @RevGeocodeId = SCOPE_IDENTITY()
									
							
			


GO
