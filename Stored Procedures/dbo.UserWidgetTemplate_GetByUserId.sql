SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the UserWidgetTemplate table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserWidgetTemplate_GetByUserId]
(

	@UserId uniqueidentifier   
)
AS


				SET ANSI_NULLS OFF
				
				SELECT
					[UserID],
					[WidgetTemplateID],
					[Archived],
					[UsageCount]
				FROM
					[dbo].[UserWidgetTemplate]
				WHERE
                            [UserID] = @UserId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
