SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the GeofenceCategory table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GeofenceCategory_Insert]
(

	@GeofenceCategoryId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@Colour nvarchar (10)  ,

	@LastModified datetime   ,

	@Archived bit   
)
AS


				
				INSERT INTO [dbo].[GeofenceCategory]
					(
					[GeofenceCategoryId]
					,[Name]
					,[Description]
					,[Colour]
					,[LastModified]
					,[Archived]
					)
				VALUES
					(
					@GeofenceCategoryId
					,@Name
					,@Description
					,@Colour
					,@LastModified
					,@Archived
					)
				
									
							
			


GO
