SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the HardwareSupplier table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[HardwareSupplier_Update]
(

	@HardwareSupplierId int   ,

	@OriginalHardwareSupplierId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[HardwareSupplier]
				SET
					[HardwareSupplierId] = @HardwareSupplierId
					,[Name] = @Name
					,[Description] = @Description
					,[Archived] = @Archived
				WHERE
[HardwareSupplierId] = @OriginalHardwareSupplierId 
				
			


GO
