SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_UnitInfo_UpdateLastComs]
(
	@VehicleId nchar(10),
	@LastComs NVARCHAR(20)
)
AS
BEGIN
	
	UPDATE dbo.UnitInfo
	SET LastComs = @LastComs
	WHERE VehicleId = @VehicleId
	
END




GO
