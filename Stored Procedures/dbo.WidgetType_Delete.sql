SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the WidgetType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetType_Delete]
(

	@WidgetTypeId int   
)
AS


                    UPDATE [dbo].[WidgetType]
                    SET Archived = 1
				WHERE
					[WidgetTypeID] = @WidgetTypeId
					
			


GO
