SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the VehicleAnalogIoData table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleAnalogIoData_Update]
(

	@VehicleAnalogIoDataId bigint   ,

	@OriginalVehicleAnalogIoDataId bigint   ,

	@VehicleIntId int   ,

	@DriverIntId int   ,

	@EventDateTime datetime   ,

	@Lat float   ,

	@SafeNameLong float   ,

	@Speed tinyint   ,

	@KeyOn bit   ,

	@Value varchar (MAX)  ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[VehicleAnalogIoData]
				SET
					[VehicleAnalogIoDataId] = @VehicleAnalogIoDataId
					,[VehicleIntId] = @VehicleIntId
					,[DriverIntId] = @DriverIntId
					,[EventDateTime] = @EventDateTime
					,[Lat] = @Lat
					,[Long] = @SafeNameLong
					,[Speed] = @Speed
					,[KeyOn] = @KeyOn
					,[Value] = @Value
					,[Archived] = @Archived
				WHERE
[VehicleAnalogIoDataId] = @OriginalVehicleAnalogIoDataId 
				
			


GO
