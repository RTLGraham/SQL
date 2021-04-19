SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the TachoMode table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TachoMode_Delete]
(

	@TachoModeId int   
)
AS


                    UPDATE [dbo].[TachoMode]
                    SET Archived = 1
				WHERE
					[TachoModeID] = @TachoModeId
					
			


GO
