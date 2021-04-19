SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the MessageVehicle table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageVehicle_Get_List]

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
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
