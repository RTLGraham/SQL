SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_WriteVehicleVehicleType] @vid uniqueidentifier = NULL, @vehicletypeid int = NULL
AS

Update Vehicle Set VehicleTypeID = @vehicletypeid Where VehicleID = @vid



GO
