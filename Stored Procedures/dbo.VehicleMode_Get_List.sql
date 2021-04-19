SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the VehicleMode table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleMode_Get_List]

AS


				
				SELECT
					[VehicleModeID],
					[Name],
					[Description],
					[Archived]
				FROM
					[dbo].[VehicleMode]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
