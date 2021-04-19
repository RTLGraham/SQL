SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the VehicleModeCreationCode table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleModeCreationCode_GetByCreationCodeIdVehicleModeId]
(

	@CreationCodeId smallint   ,

	@VehicleModeId int   
)
AS


				SELECT
					[CreationCodeId],
					[VehicleModeId]
				FROM
					[dbo].[VehicleModeCreationCode]
				WHERE
					[CreationCodeId] = @CreationCodeId
					AND [VehicleModeId] = @VehicleModeId
				SELECT @@ROWCOUNT
					
			


GO
