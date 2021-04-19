SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the AnalogIoAlertType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[AnalogIoAlertType_Get_List]

AS


				
				SELECT
					[AnalogIoAlertTypeId],
					[Name],
					[Description],
					[LastModified],
					[Archived]
				FROM
					[dbo].[AnalogIoAlertType]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
