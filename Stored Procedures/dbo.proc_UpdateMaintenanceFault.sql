SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_UpdateMaintenanceFault]
(
	@maintenanceFaultId INT,
	@assetTypeId SMALLINT NULL,
	@assetReference NVARCHAR(100) NULL,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN

	UPDATE dbo.MaintenanceFault
	SET AssetTypeId = ISNULL(@assetTypeId, AssetTypeId),
		AssetReference = ISNULL(@assetReference, AssetReference),
		AcknowledgedBy = @uid
	WHERE MaintenanceFaultId = @maintenanceFaultId

END


	



GO
