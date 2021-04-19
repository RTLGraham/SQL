SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the LanguageCulture table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[LanguageCulture_Get_List]

AS


				
				SELECT
					[LanguageCultureID],
					[Name],
					[Code],
					[Description],
					[HardwareIndex],
					[Archived]
				FROM
					[dbo].[LanguageCulture]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
