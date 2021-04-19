SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the VehicleModeCreationCode table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleModeCreationCode_Insert]
(

	@CreationCodeId smallint   ,

	@VehicleModeId int   
)
AS


				
				INSERT INTO [dbo].[VehicleModeCreationCode]
					(
					[CreationCodeId]
					,[VehicleModeId]
					)
				VALUES
					(
					@CreationCodeId
					,@VehicleModeId
					)
				
									
							
			


GO
