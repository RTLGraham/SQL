SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the TAN_TriggerType table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerType_GetByName]
(

	@Name varchar (255)  
)
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
				WHERE
					[Name] = @Name
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
