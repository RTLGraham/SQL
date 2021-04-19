SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the VehicleAnalogIoData table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleAnalogIoData_GetByVehicleAnalogIoDataId]
(

	@VehicleAnalogIoDataId bigint   
)
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
				WHERE
					[VehicleAnalogIoDataId] = @VehicleAnalogIoDataId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
