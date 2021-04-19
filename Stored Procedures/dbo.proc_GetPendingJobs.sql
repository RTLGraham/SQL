SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_GetPendingJobs]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	VehicleJobId AS Id,
	        i.TrackerNumber AS UnitId,
	        UnitProperty,
	        Job AS 'Value',
	        CreatedDate AS DateOfRequest
	FROM dbo.VehicleJob vj
	INNER JOIN dbo.IVH i ON vj.IVHId = i.IVHId
	WHERE vj.StatusInd = 0

END



GO
