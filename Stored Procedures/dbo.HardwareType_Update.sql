SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the HardwareType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[HardwareType_Update]
(

	@HardwareTypeId int   ,

	@OriginalHardwareTypeId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@HardwareSupplierId int   ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[HardwareType]
				SET
					[HardwareTypeId] = @HardwareTypeId
					,[Name] = @Name
					,[Description] = @Description
					,[HardwareSupplierId] = @HardwareSupplierId
					,[Archived] = @Archived
				WHERE
[HardwareTypeId] = @OriginalHardwareTypeId 
				
			


GO
