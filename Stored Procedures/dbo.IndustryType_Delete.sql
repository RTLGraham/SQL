SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the IndustryType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[IndustryType_Delete]
(

	@IndustryTypeId int   
)
AS


                    UPDATE [dbo].[IndustryType]
                    SET Archived = 1
				WHERE
					[IndustryTypeId] = @IndustryTypeId
					
			


GO
