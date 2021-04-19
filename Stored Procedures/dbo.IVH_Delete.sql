SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the IVH table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[IVH_Delete]
(

	@IvhId uniqueidentifier   
)
AS


                    UPDATE [dbo].[IVH]
                    SET Archived = 1
				WHERE
					[IVHId] = @IvhId
					
			


GO
