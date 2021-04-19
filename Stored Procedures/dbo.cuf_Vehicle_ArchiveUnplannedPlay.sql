SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_ArchiveUnplannedPlay]
(
	@VehicleUnplannedPlayId INT
)
AS
	EXECUTE [dbo].[proc_ArchiveUnplannedPlay]  @VehicleUnplannedPlayId

GO
