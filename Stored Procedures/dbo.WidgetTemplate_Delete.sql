SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the WidgetTemplate table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplate_Delete]
(

	@WidgetTemplateId uniqueidentifier   
)
AS


                    UPDATE [dbo].[WidgetTemplate]
                    SET Archived = 1
				WHERE
					[WidgetTemplateID] = @WidgetTemplateId
					
			


GO
