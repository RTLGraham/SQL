SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the WidgetType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetType_Insert]
(

	@WidgetTypeId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				INSERT INTO [dbo].[WidgetType]
					(
					[WidgetTypeID]
					,[Name]
					,[Description]
					,[Archived]
					)
				VALUES
					(
					@WidgetTypeId
					,@Name
					,@Description
					,@Archived
					)
				
									
							
			


GO
