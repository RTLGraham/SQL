SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the GroupTypeTables table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GroupTypeTables_Get_List]

AS


				
				SELECT
					[GroupTypeId],
					[EntityTableName],
					[EntityTablePrimaryKey],
					[EntityProc]
				FROM
					[dbo].[GroupTypeTables]

				SELECT @@ROWCOUNT
			


GO
