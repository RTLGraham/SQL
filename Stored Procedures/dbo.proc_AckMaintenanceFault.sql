SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[proc_AckMaintenanceFault]
(
	@maintenanceFaultId INT,
	@uid UNIQUEIDENTIFIER
)
AS

UPDATE dbo.MaintenanceFault
SET AcknowledgedBy = @uid	
WHERE MaintenanceFaultId = @maintenanceFaultId
	




GO
