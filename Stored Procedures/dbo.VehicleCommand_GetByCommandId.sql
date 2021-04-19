SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the VehicleCommand table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleCommand_GetByCommandId]
(

	@CommandId int   
)
AS


				SELECT
					[IVHId],
					[Command],
					[ExpiryDate],
					[AcknowledgedDate],
					[LastOperation],
					[Archived],
					[CommandId]
				FROM
					[dbo].[VehicleCommand]
				WHERE
					[CommandId] = @CommandId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
