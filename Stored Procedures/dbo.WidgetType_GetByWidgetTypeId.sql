SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the WidgetType table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetType_GetByWidgetTypeId]
(

	@WidgetTypeId int   
)
AS


				SELECT
					[WidgetTypeID],
					[Name],
					[Description],
					[Archived]
				FROM
					[dbo].[WidgetType]
				WHERE
					[WidgetTypeID] = @WidgetTypeId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
