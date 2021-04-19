SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the VehicleModeCreationCode table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleModeCreationCode_Update]
(

	@CreationCodeId smallint   ,

	@OriginalCreationCodeId smallint   ,

	@VehicleModeId int   ,

	@OriginalVehicleModeId int   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[VehicleModeCreationCode]
				SET
					[CreationCodeId] = @CreationCodeId
					,[VehicleModeId] = @VehicleModeId
				WHERE
[CreationCodeId] = @OriginalCreationCodeId 
AND [VehicleModeId] = @OriginalVehicleModeId 
				
			


GO
