SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_CommandReadAllUnAckVerbose]
AS
-- Reads only Command that are not expired

SELECT commandid, cast(command AS VARCHAR(1000)), expirydate, IVH.trackernumber, registration
FROM Command
INNER JOIN IVH ON Command.IVHIntId = IVH.IVHIntId
inner join Vehicle v on v.ivhid = IVH.ivhid
WHERE Command.Archived = 0 AND IVH.Archived = 0 
	AND Command.ExpiryDate > getdate()
	AND Command.AcknowledgedDate is null

GO
