SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the HardwareSupplier table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[HardwareSupplier_Get_List]

AS


				
				SELECT
					[HardwareSupplierId],
					[Name],
					[Description],
					[Archived]
				FROM
					[dbo].[HardwareSupplier]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
