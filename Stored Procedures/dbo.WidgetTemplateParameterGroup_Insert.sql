SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the WidgetTemplateParameterGroup table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateParameterGroup_Insert]
(

	@WidgetTemplateId uniqueidentifier   ,

	@GroupId uniqueidentifier   ,

	@GroupTypeId int   
)
AS


				
				INSERT INTO [dbo].[WidgetTemplateParameterGroup]
					(
					[WidgetTemplateID]
					,[GroupID]
					,[GroupTypeID]
					)
				VALUES
					(
					@WidgetTemplateId
					,@GroupId
					,@GroupTypeId
					)
				
									
							
			


GO
