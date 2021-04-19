SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the MessageVehicle table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageVehicle_GetByMessageIdVehicleId]
(

	@MessageId int   ,

	@VehicleId uniqueidentifier   
)
AS


				SELECT
					[MessageId],
					[VehicleId],
					[UserId],
					[CommandId],
					[TimeSent],
					[MessageStatusHardwareId],
					[MessageStatusWetwareId],
					[LastModified],
					[Archived],
					[HasBeenDeleted]
				FROM
					[dbo].[MessageVehicle]
				WHERE
					[MessageId] = @MessageId
					AND [VehicleId] = @VehicleId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
