SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ProcessVehicleCommandEventData] 
AS
BEGIN

	SET NOCOUNT ON;

	-- Mark all relevant rows in EventDataVehicleCommand ready to process
	UPDATE dbo.EventDataVehicleCommand
	SET Archived = 1 

	UPDATE dbo.VehicleCommand
	SET ReceivedDate = edvc.EventDateTime
	FROM dbo.EventDataVehicleCommand edvc
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = edvc.VehicleIntId
	INNER JOIN dbo.VehicleCommand vc ON vc.IVHId = v.IVHId 
									 AND CAST(vc.Command AS VARCHAR(1024)) LIKE LEFT(edvc.EventDataString, CASE WHEN CHARINDEX(';PW=', edvc.EventDataString) = 0 THEN LEN(edvc.EventDataString) ELSE CHARINDEX(';PW=', edvc.EventDataString)-1 END) + '%'
									 AND vc.AcknowledgedDate IS NOT NULL 
									 AND vc.ReceivedDate IS NULL
									 AND vc.ExpiryDate > GETDATE() 
	WHERE edvc.Archived = 1

	-- Clean up processed rows
	DELETE FROM dbo.EventDataVehicleCommand
	WHERE archived = 1 
	
END



GO
