SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the CustomerPreference table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CustomerPreference_GetByNameId]
(

	@NameId int   
)
AS


				SET ANSI_NULLS OFF
				
				SELECT
					[CustomerPreferenceID],
					[CustomerID],
					[NameID],
					[Value],
					[Archived]
				FROM
					[dbo].[CustomerPreference]
				WHERE
                            [NameID] = @NameId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
