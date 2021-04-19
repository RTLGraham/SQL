SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the VehicleAnalogIoData table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleAnalogIoData_GetByDriverIntId]
(

	@DriverIntId int   
)
AS


				SET ANSI_NULLS OFF
				
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
                            [DriverIntId] = @DriverIntId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
