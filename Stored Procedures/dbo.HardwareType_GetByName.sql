SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the HardwareType table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[HardwareType_GetByName]
(

	@Name nvarchar (255)  
)
AS


				SELECT
					[HardwareTypeId],
					[Name],
					[Description],
					[HardwareSupplierId],
					[Archived]
				FROM
					[dbo].[HardwareType]
				WHERE
					[Name] = @Name
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
