SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the VehicleMode table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleMode_Insert]
(

	@VehicleModeId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				INSERT INTO [dbo].[VehicleMode]
					(
					[VehicleModeID]
					,[Name]
					,[Description]
					,[Archived]
					)
				VALUES
					(
					@VehicleModeId
					,@Name
					,@Description
					,@Archived
					)
				
									
							
			


GO
