SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the TAN_NotificationType table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_NotificationType_GetByNotificationTypeId]
(

	@NotificationTypeId int   
)
AS


				SELECT
					[NotificationTypeId],
					[Name],
					[Description],
					[Archived],
					[LastOperation]
				FROM
					[dbo].[TAN_NotificationType]
				WHERE
					[NotificationTypeId] = @NotificationTypeId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
