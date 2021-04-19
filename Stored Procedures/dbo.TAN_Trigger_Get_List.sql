SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the TAN_Trigger table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_Trigger_Get_List]

AS


				
				SELECT
					[TriggerId],
					[TriggerTypeId],
					[Name],
					[Description],
					[Disabled],
					[Archived],
					[LastOperation],
					[CustomerId],
					[CreatedBy],
					[Count]
				FROM
					[dbo].[TAN_Trigger]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
