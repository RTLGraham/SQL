SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the DigitalSensorType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DigitalSensorType_Get_List]

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
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
