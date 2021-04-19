SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the GroupTypeTables table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GroupTypeTables_Delete]
(

	@GroupTypeId int   
)
AS


				    DELETE FROM [dbo].[GroupTypeTables] WITH (ROWLOCK) 
				WHERE
					[GroupTypeId] = @GroupTypeId
					
			


GO
