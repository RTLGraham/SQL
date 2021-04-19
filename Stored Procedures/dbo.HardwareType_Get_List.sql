SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the HardwareType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[HardwareType_Get_List]

AS


				
				SELECT
					[HardwareTypeId],
					[Name],
					[Description],
					[HardwareSupplierId],
					[Archived]
				FROM
					[dbo].[HardwareType]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
