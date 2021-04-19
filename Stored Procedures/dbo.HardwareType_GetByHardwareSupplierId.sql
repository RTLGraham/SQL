SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the HardwareType table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[HardwareType_GetByHardwareSupplierId]
(

	@HardwareSupplierId int   
)
AS


				SET ANSI_NULLS OFF
				
				SELECT
					[HardwareTypeId],
					[Name],
					[Description],
					[HardwareSupplierId],
					[Archived]
				FROM
					[dbo].[HardwareType]
				WHERE
                            [HardwareSupplierId] = @HardwareSupplierId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
