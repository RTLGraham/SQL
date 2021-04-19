SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the VehicleMode table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleMode_GetByName]
(

	@Name nvarchar (255)  
)
AS


				SELECT
					[VehicleModeID],
					[Name],
					[Description],
					[Archived]
				FROM
					[dbo].[VehicleMode]
				WHERE
					[Name] = @Name
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
