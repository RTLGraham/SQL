SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_DailyPassengerCountReset]
AS
BEGIN

-- This stored procedure resets the last known passenger end count to zero. 
-- It is used to initialise the passenger count prior to the start of each day.

	DECLARE @Data TABLE
	(
		VehicleId UNIQUEIDENTIFIER,
		PassengerCountId BIGINT
	)

	INSERT INTO @Data (VehicleId, PassengerCountId)
	SELECT VehicleId, MAX(PassengerCountId)
	FROM dbo.PassengerCount
	GROUP BY VehicleId

	UPDATE dbo.PassengerCount
	SET EndPassengerCount = 0,
		CalibrationFlag = -1
	FROM dbo.PassengerCount pc
	INNER JOIN @Data d ON pc.PassengerCountId = d.PassengerCountId

	-- Update VehicleLatestEvent
	UPDATE dbo.VehicleLatestEvent
	SET PaxCount = 0
	FROM dbo.VehicleLatestEvent vle
	INNER JOIN @Data d ON vle.VehicleId = d.VehicleId
	
END
GO
