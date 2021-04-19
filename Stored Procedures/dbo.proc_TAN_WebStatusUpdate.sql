SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_TAN_WebStatusUpdate] 
	@vid uniqueidentifier, @TriggerTypeId int
AS

-- This procedure hard codes the relationship between TriggerTypeId and AnalogIoAlertTypeId
UPDATE dbo.VehicleLatestEvent
SET	AnalogIoAlertTypeId = 
	CASE @TriggerTypeId
		WHEN 1 THEN 6 -- Red Panic
		WHEN 2 THEN 5 -- Blue Temp
		WHEN 3 THEN 4 -- Yellow Temp
		WHEN 4 THEN 3 -- Orange Temp
		WHEN 5 THEN 2 -- Red Temp
		WHEN 6 THEN 1 -- Clear Temp
		WHEN 23 THEN 13 -- Geofence Delay
		WHEN 24 THEN 11 -- Geofence Entry
		WHEN 25 THEN 12 -- Exit Geofence
		ELSE NULL -- No status
	END
WHERE VehicleId = @vid

GO
