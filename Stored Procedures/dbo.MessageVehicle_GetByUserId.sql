SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the MessageVehicle table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageVehicle_GetByUserId]
(

	@UserId uniqueidentifier   
)
AS


				SET ANSI_NULLS OFF
				
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
                            [UserId] = @UserId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
