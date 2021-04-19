SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the WidgetType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetType_Get_List]

AS


				
				SELECT
					[WidgetTypeID],
					[Name],
					[Description],
					[Archived]
				FROM
					[dbo].[WidgetType]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
