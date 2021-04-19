SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the Vehicle table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Vehicle_GetByVehicleIntId]
(

	@VehicleIntId int   
)
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
				WHERE
					[VehicleIntId] = @VehicleIntId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT

GO
