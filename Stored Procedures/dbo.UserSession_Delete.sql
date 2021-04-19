SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the UserSession table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserSession_Delete]
(

	@SessionId uniqueidentifier   
)
AS


				    DELETE FROM [dbo].[UserSession] WITH (ROWLOCK) 
				WHERE
					[SessionID] = @SessionId
					
			


GO
