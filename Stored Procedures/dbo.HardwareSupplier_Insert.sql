SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the HardwareSupplier table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[HardwareSupplier_Insert]
(

	@HardwareSupplierId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				INSERT INTO [dbo].[HardwareSupplier]
					(
					[HardwareSupplierId]
					,[Name]
					,[Description]
					,[Archived]
					)
				VALUES
					(
					@HardwareSupplierId
					,@Name
					,@Description
					,@Archived
					)
				
									
							
			


GO
