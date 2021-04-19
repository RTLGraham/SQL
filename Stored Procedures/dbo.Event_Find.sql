SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the Event table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Event_Find]
(

	@SearchUsingOR bit   = null ,

	@EventId bigint   = null ,

	@VehicleIntId int   = null ,

	@DriverIntId int   = null ,

	@CreationCodeId smallint   = null ,

	@SafeNameLong float   = null ,

	@Lat float   = null ,

	@Heading smallint   = null ,

	@Speed smallint   = null ,

	@OdoGps int   = null ,

	@OdoRoadSpeed int   = null ,

	@OdoDashboard int   = null ,

	@EventDateTime datetime   = null ,

	@DigitalIo tinyint   = null ,

	@CustomerIntId int   = null ,

	@AnalogData0 smallint   = null ,

	@AnalogData1 smallint   = null ,

	@AnalogData2 smallint   = null ,

	@AnalogData3 smallint   = null ,

	@AnalogData4 smallint   = null ,

	@AnalogData5 smallint   = null ,

	@SeqNumber int   = null ,

	@SpeedLimit tinyint   = null ,

	@Lastoperation smalldatetime   = null ,

	@Archived bit   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [EventId]
	, [VehicleIntId]
	, [DriverIntId]
	, [CreationCodeId]
	, [Long]
	, [Lat]
	, [Heading]
	, [Speed]
	, [OdoGPS]
	, [OdoRoadSpeed]
	, [OdoDashboard]
	, [EventDateTime]
	, [DigitalIO]
	, [CustomerIntId]
	, [AnalogData0]
	, [AnalogData1]
	, [AnalogData2]
	, [AnalogData3]
	, [AnalogData4]
	, [AnalogData5]
	, [SeqNumber]
	, [SpeedLimit]
	, [Lastoperation]
	, [Archived]
    FROM
	[dbo].[Event]
    WHERE 
	 ([EventId] = @EventId OR @EventId IS NULL)
	AND ([VehicleIntId] = @VehicleIntId OR @VehicleIntId IS NULL)
	AND ([DriverIntId] = @DriverIntId OR @DriverIntId IS NULL)
	AND ([CreationCodeId] = @CreationCodeId OR @CreationCodeId IS NULL)
	AND ([Long] = @SafeNameLong OR @SafeNameLong IS NULL)
	AND ([Lat] = @Lat OR @Lat IS NULL)
	AND ([Heading] = @Heading OR @Heading IS NULL)
	AND ([Speed] = @Speed OR @Speed IS NULL)
	AND ([OdoGPS] = @OdoGps OR @OdoGps IS NULL)
	AND ([OdoRoadSpeed] = @OdoRoadSpeed OR @OdoRoadSpeed IS NULL)
	AND ([OdoDashboard] = @OdoDashboard OR @OdoDashboard IS NULL)
	AND ([EventDateTime] = @EventDateTime OR @EventDateTime IS NULL)
	AND ([DigitalIO] = @DigitalIo OR @DigitalIo IS NULL)
	AND ([CustomerIntId] = @CustomerIntId OR @CustomerIntId IS NULL)
	AND ([AnalogData0] = @AnalogData0 OR @AnalogData0 IS NULL)
	AND ([AnalogData1] = @AnalogData1 OR @AnalogData1 IS NULL)
	AND ([AnalogData2] = @AnalogData2 OR @AnalogData2 IS NULL)
	AND ([AnalogData3] = @AnalogData3 OR @AnalogData3 IS NULL)
	AND ([AnalogData4] = @AnalogData4 OR @AnalogData4 IS NULL)
	AND ([AnalogData5] = @AnalogData5 OR @AnalogData5 IS NULL)
	AND ([SeqNumber] = @SeqNumber OR @SeqNumber IS NULL)
	AND ([SpeedLimit] = @SpeedLimit OR @SpeedLimit IS NULL)
	AND ([Lastoperation] = @Lastoperation OR @Lastoperation IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [EventId]
	, [VehicleIntId]
	, [DriverIntId]
	, [CreationCodeId]
	, [Long]
	, [Lat]
	, [Heading]
	, [Speed]
	, [OdoGPS]
	, [OdoRoadSpeed]
	, [OdoDashboard]
	, [EventDateTime]
	, [DigitalIO]
	, [CustomerIntId]
	, [AnalogData0]
	, [AnalogData1]
	, [AnalogData2]
	, [AnalogData3]
	, [AnalogData4]
	, [AnalogData5]
	, [SeqNumber]
	, [SpeedLimit]
	, [Lastoperation]
	, [Archived]
    FROM
	[dbo].[Event]
    WHERE 
	 ([EventId] = @EventId AND @EventId is not null)
	OR ([VehicleIntId] = @VehicleIntId AND @VehicleIntId is not null)
	OR ([DriverIntId] = @DriverIntId AND @DriverIntId is not null)
	OR ([CreationCodeId] = @CreationCodeId AND @CreationCodeId is not null)
	OR ([Long] = @SafeNameLong AND @SafeNameLong is not null)
	OR ([Lat] = @Lat AND @Lat is not null)
	OR ([Heading] = @Heading AND @Heading is not null)
	OR ([Speed] = @Speed AND @Speed is not null)
	OR ([OdoGPS] = @OdoGps AND @OdoGps is not null)
	OR ([OdoRoadSpeed] = @OdoRoadSpeed AND @OdoRoadSpeed is not null)
	OR ([OdoDashboard] = @OdoDashboard AND @OdoDashboard is not null)
	OR ([EventDateTime] = @EventDateTime AND @EventDateTime is not null)
	OR ([DigitalIO] = @DigitalIo AND @DigitalIo is not null)
	OR ([CustomerIntId] = @CustomerIntId AND @CustomerIntId is not null)
	OR ([AnalogData0] = @AnalogData0 AND @AnalogData0 is not null)
	OR ([AnalogData1] = @AnalogData1 AND @AnalogData1 is not null)
	OR ([AnalogData2] = @AnalogData2 AND @AnalogData2 is not null)
	OR ([AnalogData3] = @AnalogData3 AND @AnalogData3 is not null)
	OR ([AnalogData4] = @AnalogData4 AND @AnalogData4 is not null)
	OR ([AnalogData5] = @AnalogData5 AND @AnalogData5 is not null)
	OR ([SeqNumber] = @SeqNumber AND @SeqNumber is not null)
	OR ([SpeedLimit] = @SpeedLimit AND @SpeedLimit is not null)
	OR ([Lastoperation] = @Lastoperation AND @Lastoperation is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
