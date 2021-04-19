SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_GetVehicleWithLocation]
(
	@VehicleId UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER = NULL,
	@date DATETIME = NULL
)
AS

SELECT *
FROM [dbo].[Vehicle]
WHERE VehicleId = @VehicleId

EXECUTE cuf_Vehicle_GetVehicleDetails @VehicleId, @uid, @date

GO
