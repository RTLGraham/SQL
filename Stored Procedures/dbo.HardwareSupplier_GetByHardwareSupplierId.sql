SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the HardwareSupplier table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[HardwareSupplier_GetByHardwareSupplierId]
(

	@HardwareSupplierId int   
)
AS


				SELECT
					[HardwareSupplierId],
					[Name],
					[Description],
					[Archived]
				FROM
					[dbo].[HardwareSupplier]
				WHERE
					[HardwareSupplierId] = @HardwareSupplierId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
