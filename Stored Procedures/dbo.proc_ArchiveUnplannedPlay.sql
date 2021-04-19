SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ArchiveUnplannedPlay]
(
	@VehicleUnplannedPlayId INT
)
AS

	UPDATE dbo.VehicleUnplannedPlay
	SET Archived = 1
	WHERE VehicleUnplannedPlayId = @VehicleUnplannedPlayId

GO
