SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the CustomerPreference table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CustomerPreference_Delete]
(

	@CustomerPreferenceId uniqueidentifier   
)
AS


                    UPDATE [dbo].[CustomerPreference]
                    SET Archived = 1
				WHERE
					[CustomerPreferenceID] = @CustomerPreferenceId
					
			


GO
