SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the TAN_TriggerParam table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerParam_Get_List]

AS


				
				SELECT
					[TriggerId],
					[TriggerParamTypeId],
					[TriggerParamTypeValue],
					[Archived],
					[LastOperation],
					[Count]
				FROM
					[dbo].[TAN_TriggerParam]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
