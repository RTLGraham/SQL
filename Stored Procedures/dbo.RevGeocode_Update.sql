SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the RevGeocode table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[RevGeocode_Update]
(

	@RevGeocodeId int   ,

	@SafeNameLong float   ,

	@Lat float   ,

	@Address varchar (100)  ,

	@Postcode varchar (50)  ,

	@Archived bit   ,

	@LatLongIdx bigint   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[RevGeocode]
				SET
					[Long] = @SafeNameLong
					,[Lat] = @Lat
					,[Address] = @Address
					,[Postcode] = @Postcode
					,[Archived] = @Archived
					,[LatLongIdx] = @LatLongIdx
				WHERE
[RevGeocodeId] = @RevGeocodeId 
				
			


GO
