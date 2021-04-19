SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the TAN_NotificationTemplate table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_NotificationTemplate_GetByTriggerId]
(

	@TriggerId uniqueidentifier   
)
AS


				SET ANSI_NULLS OFF
				
				SELECT
					[NotificationTemplateId],
					[TriggerId],
					[NotificationTypeId],
					[Header],
					[Body],
					[Disabled],
					[Archived],
					[LastOperation],
					[Count]
				FROM
					[dbo].[TAN_NotificationTemplate]
				WHERE
                            [TriggerId] = @TriggerId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
