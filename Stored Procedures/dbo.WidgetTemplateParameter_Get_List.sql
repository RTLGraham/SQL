SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the WidgetTemplateParameter table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateParameter_Get_List]

AS


				
				SELECT
					[WidgetTemplateParameterID],
					[WidgetTemplateID],
					[NameID],
					[Value],
					[Archived]
				FROM
					[dbo].[WidgetTemplateParameter]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
