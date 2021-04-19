SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the IndicatorConfig table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[IndicatorConfig_Delete]
(

	@IndicatorConfigId int   
)
AS


                    UPDATE [dbo].[IndicatorConfig]
                    SET Archived = 1
				WHERE
					[IndicatorConfigId] = @IndicatorConfigId
					
			


GO
