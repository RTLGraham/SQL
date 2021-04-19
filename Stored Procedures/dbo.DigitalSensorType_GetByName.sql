SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the DigitalSensorType table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DigitalSensorType_GetByName]
(

	@Name nvarchar (254)  
)
AS


				SELECT
					[DigitalSensorTypeId],
					[Name],
					[Description],
					[OnDescription],
					[OffDescription],
					[IconLocation],
					[LastOperation],
					[Archived]
				FROM
					[dbo].[DigitalSensorType]
				WHERE
					[Name] = @Name
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
