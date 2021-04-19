SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the TAN_NotificationTemplate table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_NotificationTemplate_Delete]
(

	@NotificationTemplateId uniqueidentifier   
)
AS


                    DELETE [dbo].[TAN_NotificationTemplate]
				WHERE
					[NotificationTemplateId] = @NotificationTemplateId
					
			


GO
