SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the TAN_TriggerType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerType_Get_List]

AS


				
				SELECT
					[TriggerTypeId],
					[Name],
					[Description],
					[CreationCodeId],
					[Archived],
					[LastOperation]
				FROM
					[dbo].[TAN_TriggerType]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
