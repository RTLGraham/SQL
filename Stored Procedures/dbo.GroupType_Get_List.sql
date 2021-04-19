SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the GroupType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GroupType_Get_List]

AS


				
				SELECT
					[GroupTypeId],
					[GroupTypeName],
					[GroupTypeDescription]
				FROM
					[dbo].[GroupType]

				SELECT @@ROWCOUNT
			


GO
