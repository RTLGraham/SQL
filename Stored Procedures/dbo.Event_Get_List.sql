SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the Event table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Event_Get_List]

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
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
