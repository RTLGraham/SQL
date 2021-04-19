SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the IVH table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[IVH_Get_List]

AS


				
				SELECT
					[IVHId],
					[IVHIntId],
					[TrackerNumber],
					[Manufacturer],
					[Model],
					[PacketType],
					[PhoneNumber],
					[SIMCardNumber],
					[ServiceProvider],
					[SerialNumber],
					[FirmwareVersion],
					[AntennaType],
					[LastOperation],
					[Archived],
					[IsTag],
					[IVHTypeId]
				FROM
					[dbo].[IVH]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
