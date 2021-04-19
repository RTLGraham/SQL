SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the WidgetType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetType_Update]
(

	@WidgetTypeId int   ,

	@OriginalWidgetTypeId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[WidgetType]
				SET
					[WidgetTypeID] = @WidgetTypeId
					,[Name] = @Name
					,[Description] = @Description
					,[Archived] = @Archived
				WHERE
[WidgetTypeID] = @OriginalWidgetTypeId 
				
			


GO
