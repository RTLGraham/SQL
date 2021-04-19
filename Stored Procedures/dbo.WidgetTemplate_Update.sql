SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the WidgetTemplate table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplate_Update]
(

	@WidgetTemplateId uniqueidentifier   ,

	@WidgetTypeId int   ,

	@Name nvarchar (255)  ,

	@ThumbnailRelativePath nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[WidgetTemplate]
				SET
					[WidgetTypeID] = @WidgetTypeId
					,[Name] = @Name
					,[ThumbnailRelativePath] = @ThumbnailRelativePath
					,[Archived] = @Archived
				WHERE
[WidgetTemplateID] = @WidgetTemplateId 
				
			


GO
