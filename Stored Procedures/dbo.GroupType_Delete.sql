SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the GroupType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GroupType_Delete]
(

	@GroupTypeId int   
)
AS


				    DELETE FROM [dbo].[GroupType] WITH (ROWLOCK) 
				WHERE
					[GroupTypeId] = @GroupTypeId
					
			


GO
