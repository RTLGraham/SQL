SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the GeofenceType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GeofenceType_Insert]
(

	@GeofenceTypeId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				INSERT INTO [dbo].[GeofenceType]
					(
					[GeofenceTypeId]
					,[Name]
					,[Description]
					,[Archived]
					)
				VALUES
					(
					@GeofenceTypeId
					,@Name
					,@Description
					,@Archived
					)
				
									
							
			


GO
