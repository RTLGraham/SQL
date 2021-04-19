SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the CustomerPreference table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CustomerPreference_Get_List]

AS


				
				SELECT
					[CustomerPreferenceID],
					[CustomerID],
					[NameID],
					[Value],
					[Archived]
				FROM
					[dbo].[CustomerPreference]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
