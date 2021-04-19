SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the GeofenceCategory table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GeofenceCategory_Update]
(

	@GeofenceCategoryId int   ,

	@OriginalGeofenceCategoryId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@Colour nvarchar (10)  ,

	@LastModified datetime   ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[GeofenceCategory]
				SET
					[GeofenceCategoryId] = @GeofenceCategoryId
					,[Name] = @Name
					,[Description] = @Description
					,[Colour] = @Colour
					,[LastModified] = @LastModified
					,[Archived] = @Archived
				WHERE
[GeofenceCategoryId] = @OriginalGeofenceCategoryId 
				
			


GO
