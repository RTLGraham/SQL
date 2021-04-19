SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the Event table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Event_Insert]
(

	@EventId bigint   ,

	@VehicleIntId int   ,

	@DriverIntId int   ,

	@CreationCodeId smallint   ,

	@SafeNameLong float   ,

	@Lat float   ,

	@Heading smallint   ,

	@Speed smallint   ,

	@OdoGps int   ,

	@OdoRoadSpeed int   ,

	@OdoDashboard int   ,

	@EventDateTime datetime   ,

	@DigitalIo tinyint   ,

	@CustomerIntId int   ,

	@AnalogData0 smallint   ,

	@AnalogData1 smallint   ,

	@AnalogData2 smallint   ,

	@AnalogData3 smallint   ,

	@AnalogData4 smallint   ,

	@AnalogData5 smallint   ,

	@SeqNumber int   ,

	@SpeedLimit tinyint   ,

	@Lastoperation smalldatetime   ,

	@Archived bit   
)
AS


				
				INSERT INTO [dbo].[Event]
					(
					[EventId]
					,[VehicleIntId]
					,[DriverIntId]
					,[CreationCodeId]
					,[Long]
					,[Lat]
					,[Heading]
					,[Speed]
					,[OdoGPS]
					,[OdoRoadSpeed]
					,[OdoDashboard]
					,[EventDateTime]
					,[DigitalIO]
					,[CustomerIntId]
					,[AnalogData0]
					,[AnalogData1]
					,[AnalogData2]
					,[AnalogData3]
					,[AnalogData4]
					,[AnalogData5]
					,[SeqNumber]
					,[SpeedLimit]
					,[Lastoperation]
					,[Archived]
					)
				VALUES
					(
					@EventId
					,@VehicleIntId
					,@DriverIntId
					,@CreationCodeId
					,@SafeNameLong
					,@Lat
					,@Heading
					,@Speed
					,@OdoGps
					,@OdoRoadSpeed
					,@OdoDashboard
					,@EventDateTime
					,@DigitalIo
					,@CustomerIntId
					,@AnalogData0
					,@AnalogData1
					,@AnalogData2
					,@AnalogData3
					,@AnalogData4
					,@AnalogData5
					,@SeqNumber
					,@SpeedLimit
					,@Lastoperation
					,@Archived
					)
				
									
							
			


GO
