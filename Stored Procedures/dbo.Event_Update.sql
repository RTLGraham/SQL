SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the Event table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Event_Update]
(

	@EventId bigint   ,

	@OriginalEventId bigint   ,

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


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[Event]
				SET
					[EventId] = @EventId
					,[VehicleIntId] = @VehicleIntId
					,[DriverIntId] = @DriverIntId
					,[CreationCodeId] = @CreationCodeId
					,[Long] = @SafeNameLong
					,[Lat] = @Lat
					,[Heading] = @Heading
					,[Speed] = @Speed
					,[OdoGPS] = @OdoGps
					,[OdoRoadSpeed] = @OdoRoadSpeed
					,[OdoDashboard] = @OdoDashboard
					,[EventDateTime] = @EventDateTime
					,[DigitalIO] = @DigitalIo
					,[CustomerIntId] = @CustomerIntId
					,[AnalogData0] = @AnalogData0
					,[AnalogData1] = @AnalogData1
					,[AnalogData2] = @AnalogData2
					,[AnalogData3] = @AnalogData3
					,[AnalogData4] = @AnalogData4
					,[AnalogData5] = @AnalogData5
					,[SeqNumber] = @SeqNumber
					,[SpeedLimit] = @SpeedLimit
					,[Lastoperation] = @Lastoperation
					,[Archived] = @Archived
				WHERE
[EventId] = @OriginalEventId 
				
			


GO
