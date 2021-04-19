SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the UserWidgetTemplate table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserWidgetTemplate_GetByUserIdWidgetTemplateId]
(

	@UserId uniqueidentifier   ,

	@WidgetTemplateId uniqueidentifier   
)
AS


				SELECT
					[UserID],
					[WidgetTemplateID],
					[Archived],
					[UsageCount]
				FROM
					[dbo].[UserWidgetTemplate]
				WHERE
					[UserID] = @UserId
					AND [WidgetTemplateID] = @WidgetTemplateId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
