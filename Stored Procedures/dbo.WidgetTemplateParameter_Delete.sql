SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the WidgetTemplateParameter table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateParameter_Delete]
(

	@WidgetTemplateParameterId uniqueidentifier   
)
AS


                    UPDATE [dbo].[WidgetTemplateParameter]
                    SET Archived = 1
				WHERE
					[WidgetTemplateParameterID] = @WidgetTemplateParameterId
					
			


GO
