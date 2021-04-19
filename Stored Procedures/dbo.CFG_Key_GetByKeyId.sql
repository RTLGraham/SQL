SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the CFG_Key table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_Key_GetByKeyId]
(

	@KeyId int   
)
AS


				SELECT
					[KeyId],
					[Name],
					[Description],
					[IndexPos],
					[Archived],
					[LastOperation]
				FROM
					[dbo].[CFG_Key]
				WHERE
					[KeyId] = @KeyId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			

GO
