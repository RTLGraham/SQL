SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the UserWidgetTemplate table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserWidgetTemplate_Delete]
(

	@UserId uniqueidentifier   ,

	@WidgetTemplateId uniqueidentifier   
)
AS


                    UPDATE [dbo].[UserWidgetTemplate]
                    SET Archived = 1
				WHERE
					[UserID] = @UserId
					AND [WidgetTemplateID] = @WidgetTemplateId
					
			


GO
