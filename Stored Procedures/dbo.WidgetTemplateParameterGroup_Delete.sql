SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the WidgetTemplateParameterGroup table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateParameterGroup_Delete]
(

	@WidgetTemplateId uniqueidentifier   ,

	@GroupId uniqueidentifier   
)
AS


				    DELETE FROM [dbo].[WidgetTemplateParameterGroup] WITH (ROWLOCK) 
				WHERE
					[WidgetTemplateID] = @WidgetTemplateId
					AND [GroupID] = @GroupId
					
			


GO
