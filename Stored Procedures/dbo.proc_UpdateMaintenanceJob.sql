SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[proc_UpdateMaintenanceJob]
(
	@maintenanceJobId INT,
	@engineerDateTime DATETIME NULL,
	@engineer NVARCHAR(100) NULL,
	@supportTicketId INT NULL,
	@resolvedInd BIT NULL,
	@uid UNIQUEIDENTIFIER NULL
)
AS

UPDATE dbo.MaintenanceJob 
SET EngineerDateTime = CASE WHEN @engineerDateTime IS NOT NULL THEN @engineerDateTime ELSE EngineerDateTime END,
	Engineer = CASE WHEN @engineer IS NOT NULL THEN @engineer ELSE Engineer END,
	SupportTicketId = CASE WHEN @supportTicketId IS NOT NULL THEN @supportTicketId ELSE SupportTicketId END,
	ResolvedDateTime = CASE WHEN ISNULL(@resolvedInd, 0) = 1 THEN GETUTCDATE() ELSE ResolvedDateTime END	
FROM dbo.MaintenanceJob mj
WHERE mj.MaintenanceJobId = @maintenanceJobId
	
-- If Job is being resolved automatically update the AcknowledgedBy for the user performing the update (where not already set)
-- Mark any faults as Acknowledged if not already
UPDATE dbo.MaintenanceFault
SET AcknowledgedBy = @uid
FROM dbo.MaintenanceFault mf
INNER JOIN dbo.MaintenanceJob mj ON mj.MaintenanceJobId = mf.MaintenanceJobId
WHERE mj.MaintenanceJobId = @maintenanceJobId
  AND mf.AcknowledgedBy IS NULL	


GO
