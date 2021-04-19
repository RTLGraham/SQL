SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the HardwareType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[HardwareType_Insert]
(

	@HardwareTypeId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@HardwareSupplierId int   ,

	@Archived bit   
)
AS


				
				INSERT INTO [dbo].[HardwareType]
					(
					[HardwareTypeId]
					,[Name]
					,[Description]
					,[HardwareSupplierId]
					,[Archived]
					)
				VALUES
					(
					@HardwareTypeId
					,@Name
					,@Description
					,@HardwareSupplierId
					,@Archived
					)
				
									
							
			


GO
