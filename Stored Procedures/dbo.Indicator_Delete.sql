SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the Indicator table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Indicator_Delete]
(

	@IndicatorId int   
)
AS


                    UPDATE [dbo].[Indicator]
                    SET Archived = 1
				WHERE
					[IndicatorId] = @IndicatorId
					
			


GO
