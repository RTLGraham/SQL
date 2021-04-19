SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_UnitInfo_UpdateJobsRead]
(
	@VehicleId nchar(10),
	@JobsRead INT
)
AS
BEGIN
	
	UPDATE dbo.UnitInfo
	SET JobsRead = @JobsRead
	WHERE VehicleId = @VehicleId
	
END




GO
