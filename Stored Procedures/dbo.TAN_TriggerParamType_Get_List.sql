SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the TAN_TriggerParamType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerParamType_Get_List]

AS


				
				SELECT
					[TriggerParamTypeId],
					[Name],
					[Description],
					[Archived],
					[LastOperation]
				FROM
					[dbo].[TAN_TriggerParamType]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
