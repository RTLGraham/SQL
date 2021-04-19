SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the VehicleAnalogIoData table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleAnalogIoData_Insert]
(

	@VehicleAnalogIoDataId bigint   ,

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


				
				INSERT INTO [dbo].[VehicleAnalogIoData]
					(
					[VehicleAnalogIoDataId]
					,[VehicleIntId]
					,[DriverIntId]
					,[EventDateTime]
					,[Lat]
					,[Long]
					,[Speed]
					,[KeyOn]
					,[Value]
					,[Archived]
					)
				VALUES
					(
					@VehicleAnalogIoDataId
					,@VehicleIntId
					,@DriverIntId
					,@EventDateTime
					,@Lat
					,@SafeNameLong
					,@Speed
					,@KeyOn
					,@Value
					,@Archived
					)
				
									
							
			


GO
