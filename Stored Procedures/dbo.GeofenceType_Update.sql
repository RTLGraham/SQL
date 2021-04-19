SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the GeofenceType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GeofenceType_Update]
(

	@GeofenceTypeId int   ,

	@OriginalGeofenceTypeId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[GeofenceType]
				SET
					[GeofenceTypeId] = @GeofenceTypeId
					,[Name] = @Name
					,[Description] = @Description
					,[Archived] = @Archived
				WHERE
[GeofenceTypeId] = @OriginalGeofenceTypeId 
				
			


GO
