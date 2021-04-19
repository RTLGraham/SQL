SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the Vehicle table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Vehicle_Get_List]

AS


				
				SELECT
					[VehicleId],
					[VehicleIntId],
					[IVHId],
					[Registration],
					[MakeModel],
					[BodyManufacturer],
					[BodyType],
					[ChassisNumber],
					[FleetNumber],
					[DisplayColour],
					[IconId],
					[Identifier],
					[Archived],
					[LastOperation],
					[ROPEnabled],
					[Notes],
					[IsTrailer],
					[FuelMultiplier],
					[VehicleTypeID],
					[IsCAN],
					[IsPrivate],
					[ClaimRate],
					[FuelTypeId],
					[EngineSize],
					[MaxPax]
				FROM
					[dbo].[Vehicle]
                WHERE Archived = 0

				SELECT @@ROWCOUNT

GO
