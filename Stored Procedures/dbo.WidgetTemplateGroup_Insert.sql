SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the WidgetTemplateGroup table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateGroup_Insert]
(

	@GroupId uniqueidentifier   ,

	@WidgetTemplateId uniqueidentifier   ,

	@Archived bit   ,

	@LastModified datetime   
)
AS


				
				INSERT INTO [dbo].[WidgetTemplateGroup]
					(
					[GroupId]
					,[WidgetTemplateId]
					,[Archived]
					,[LastModified]
					)
				VALUES
					(
					@GroupId
					,@WidgetTemplateId
					,@Archived
					,@LastModified
					)
				
									
							
			


GO
