SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the TelcoProvider table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TelcoProvider_Delete]
(

	@TelcoProviderId int   
)
AS


                    UPDATE [dbo].[TelcoProvider]
                    SET Archived = 1
				WHERE
					[TelcoProviderId] = @TelcoProviderId
					
			


GO
