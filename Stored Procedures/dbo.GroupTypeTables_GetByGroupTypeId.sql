SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the GroupTypeTables table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GroupTypeTables_GetByGroupTypeId]
(

	@GroupTypeId int   
)
AS


				SELECT
					[GroupTypeId],
					[EntityTableName],
					[EntityTablePrimaryKey],
					[EntityProc]
				FROM
					[dbo].[GroupTypeTables]
				WHERE
					[GroupTypeId] = @GroupTypeId
				SELECT @@ROWCOUNT
					
			


GO
