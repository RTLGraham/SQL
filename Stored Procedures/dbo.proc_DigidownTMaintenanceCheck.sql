SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_DigidownTMaintenanceCheck]
AS
BEGIN	

	-- Entries in the Control table with StatusId = 2 mean the vehicle/driver combination have had a successful file upload for the day in question
	-- Any entries with status 1 mean a command has been issued but no successful upload in the same day, and multiple entries indicates multiple attempts
	-- StatusId = 3 indicates and upload failure but this may have been followed by a successful upload on a subsequent attempt

	DECLARE	@VehicleId UNIQUEIDENTIFIER,
			@DriverId UNIQUEIDENTIFIER,
			@FaultTypeId INT

	DECLARE @DigiFaults TABLE
	(
		VehicleId UNIQUEIDENTIFIER NULL,
		DriverId UNIQUEIDENTIFIER NULL,
		FaultTypeId INT
	);

	WITH Digidown_CTE (VehicleIntId, DriverIntId, StatusId, StatusCount)
	AS
	(
		SELECT VehicleIntId, DriverIntid, StatusId, COUNT(*)
		FROM dbo.DigiDownTControl
		WHERE FLOOR(CAST(CommandDateTime AS FLOAT)) = FLOOR(CAST(GETUTCDATE() AS FLOAT)) - 1 -- Check results from yesterday
		GROUP BY VehicleIntId, DriverIntid, StatusId
	)

	INSERT INTO @DigiFaults (VehicleId, DriverId, FaultTypeId)
	SELECT v.VehicleId, d.DriverId, CASE WHEN d3.VehicleIntId IS NULL THEN 34 ELSE 35 END -- 34 = Download fail, 35 = Upload fail
	FROM Digidown_CTE d1
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = d1.VehicleIntId
	LEFT JOIN dbo.Driver d ON d.DriverIntId = d1.DriverIntId
	LEFT JOIN Digidown_CTE d3 ON d3.VehicleIntId = d1.VehicleIntId AND ISNULL(d3.DriverIntId, 0) = ISNULL(d1.DriverIntId, 0) AND d3.StatusId = 3
	WHERE d1.StatusId = 1
	  AND (d1.StatusCount > 4 OR d3.StatusCount > 1)

	DECLARE dCur CURSOR FAST_FORWARD READ_ONLY 
	FOR
		SELECT VehicleId, DriverId, FaultTypeId
		FROM @DigiFaults

	SET @VehicleId = NULL
	SET @DriverId = NULL
	SET @FaultTypeId = NULL

	OPEN dCur
	FETCH NEXT FROM dCur INTO @VehicleId, @DriverId, @FaultTypeId

	WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC proc_WriteProactiveMaintenance @VehicleId, @faultTypeId, 4, NULL

		FETCH NEXT FROM dCur INTO @VehicleId, @DriverId, @FaultTypeId

	END	

	CLOSE dCur
	DEALLOCATE dCur
	
END	
GO
