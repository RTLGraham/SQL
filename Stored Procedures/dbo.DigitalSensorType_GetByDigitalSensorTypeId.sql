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


CREATE PROCEDURE [dbo].[DigitalSensorType_GetByDigitalSensorTypeId]
(

	@DigitalSensorTypeId smallint   
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
					[DigitalSensorTypeId] = @DigitalSensorTypeId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
