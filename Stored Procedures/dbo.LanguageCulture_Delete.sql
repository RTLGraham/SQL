SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the LanguageCulture table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[LanguageCulture_Delete]
(

	@LanguageCultureId smallint   
)
AS


                    UPDATE [dbo].[LanguageCulture]
                    SET Archived = 1
				WHERE
					[LanguageCultureID] = @LanguageCultureId
					
			


GO
