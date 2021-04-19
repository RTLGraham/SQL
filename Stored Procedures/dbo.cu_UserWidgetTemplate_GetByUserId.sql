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


CREATE PROCEDURE [dbo].[cu_UserWidgetTemplate_GetByUserId]
(

	@UserId uniqueidentifier   ,

	@WidgetTemplateId uniqueidentifier   
)
AS


				SELECT
					[UserID],
					[WidgetTemplateID],
					[UsageCount],
					[Archived]
				FROM
					[dbo].[UserWidgetTemplate]
				WHERE
					[UserID] = @UserId
					AND [WidgetTemplateID] = @WidgetTemplateId
                                AND
                            Archived = 0
                ORDER BY [UsageCount] DESC
                
				SELECT @@ROWCOUNT

GO
