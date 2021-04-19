SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_VehicleCommandReadAllUnAck]
AS
-- Reads only Vehicle Commands that are not expired

-- read in reverse order as list org in the listener delivers them to the vehicle backwards

SELECT commandid, command, expirydate, IVH.trackernumber
FROM VehicleCommand
INNER JOIN IVH ON VehicleCommand.ivhid = IVH.ivhid
WHERE VehicleCommand.Archived = 0 AND IVH.Archived = 0 
	AND VehicleCommand.ExpiryDate > getdate()
	AND VehicleCommand.AcknowledgedDate is null
ORDER BY commandid--Command.LastOperation DESC

GO
