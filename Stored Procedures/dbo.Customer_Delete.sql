SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the Customer table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Customer_Delete]
(

	@CustomerId uniqueidentifier   
)
AS


                    UPDATE [dbo].[Customer]
                    SET Archived = 1
				WHERE
					[CustomerId] = @CustomerId
					
			


GO
