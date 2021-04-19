SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the LanguageCulture table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[LanguageCulture_GetByName]
(

	@Name nvarchar (255)  
)
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
				WHERE
					[Name] = @Name
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
