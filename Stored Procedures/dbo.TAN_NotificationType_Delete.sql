SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the TAN_NotificationType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_NotificationType_Delete]
(

	@NotificationTypeId int   
)
AS


                    UPDATE [dbo].[TAN_NotificationType]
                    SET Archived = 1
				WHERE
					[NotificationTypeId] = @NotificationTypeId
					
			


GO
