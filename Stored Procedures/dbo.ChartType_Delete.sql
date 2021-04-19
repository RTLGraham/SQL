SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the ChartType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[ChartType_Delete]
(

	@ChartTypeId int   
)
AS


                    UPDATE [dbo].[ChartType]
                    SET Archived = 1
				WHERE
					[ChartTypeId] = @ChartTypeId
					
			


GO
