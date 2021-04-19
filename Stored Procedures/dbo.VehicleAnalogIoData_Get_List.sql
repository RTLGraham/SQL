SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the VehicleAnalogIoData table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleAnalogIoData_Get_List]

AS


				
				SELECT
					[VehicleAnalogIoDataId],
					[VehicleIntId],
					[DriverIntId],
					[EventDateTime],
					[Lat],
					[Long],
					[Speed],
					[KeyOn],
					[Value],
					[Archived]
				FROM
					[dbo].[VehicleAnalogIoData]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
