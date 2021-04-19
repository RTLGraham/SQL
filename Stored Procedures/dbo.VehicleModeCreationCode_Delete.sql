SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the VehicleModeCreationCode table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleModeCreationCode_Delete]
(

	@CreationCodeId smallint   ,

	@VehicleModeId int   
)
AS


				    DELETE FROM [dbo].[VehicleModeCreationCode] WITH (ROWLOCK) 
				WHERE
					[CreationCodeId] = @CreationCodeId
					AND [VehicleModeId] = @VehicleModeId
					
			


GO
