SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the WidgetTemplate table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplate_Insert]
(

	@WidgetTemplateId uniqueidentifier    OUTPUT,

	@WidgetTypeId int   ,

	@Name nvarchar (255)  ,

	@ThumbnailRelativePath nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				Declare @IdentityRowGuids table (WidgetTemplateId uniqueidentifier	)
				INSERT INTO [dbo].[WidgetTemplate]
					(
					[WidgetTypeID]
					,[Name]
					,[ThumbnailRelativePath]
					,[Archived]
					)
						OUTPUT INSERTED.WidgetTemplateID INTO @IdentityRowGuids
					
				VALUES
					(
					@WidgetTypeId
					,@Name
					,@ThumbnailRelativePath
					,@Archived
					)
				
				SELECT @WidgetTemplateId=WidgetTemplateId	 from @IdentityRowGuids
									
							
			


GO
