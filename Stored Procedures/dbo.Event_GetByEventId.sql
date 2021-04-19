SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the Event table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Event_GetByEventId]
(

	@EventId bigint   
)
AS


				SELECT
					[EventId],
					[VehicleIntId],
					[DriverIntId],
					[CreationCodeId],
					[Long],
					[Lat],
					[Heading],
					[Speed],
					[OdoGPS],
					[OdoRoadSpeed],
					[OdoDashboard],
					[EventDateTime],
					[DigitalIO],
					[CustomerIntId],
					[AnalogData0],
					[AnalogData1],
					[AnalogData2],
					[AnalogData3],
					[AnalogData4],
					[AnalogData5],
					[SeqNumber],
					[SpeedLimit],
					[Lastoperation],
					[Archived]
				FROM
					[dbo].[Event]
				WHERE
					[EventId] = @EventId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
