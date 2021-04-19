SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the VehicleMode table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleMode_Update]
(

	@VehicleModeId int   ,

	@OriginalVehicleModeId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[VehicleMode]
				SET
					[VehicleModeID] = @VehicleModeId
					,[Name] = @Name
					,[Description] = @Description
					,[Archived] = @Archived
				WHERE
[VehicleModeID] = @OriginalVehicleModeId 
				
			


GO
