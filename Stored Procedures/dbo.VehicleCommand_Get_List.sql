SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the VehicleCommand table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleCommand_Get_List]

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
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
