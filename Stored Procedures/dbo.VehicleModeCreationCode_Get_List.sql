SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the VehicleModeCreationCode table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleModeCreationCode_Get_List]

AS


				
				SELECT
					[CreationCodeId],
					[VehicleModeId]
				FROM
					[dbo].[VehicleModeCreationCode]

				SELECT @@ROWCOUNT
			


GO
