SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_SaveVehicleSensor]
(
	@VehicleSensorId INT=NULL,
	@vid UNIQUEIDENTIFIER,
	@description NVARCHAR(MAX)=NULL,
	@shortname NVARCHAR(MAX)=NULL,
	@colour NVARCHAR(MAX)=NULL,
	@scale FLOAT,
	@enabled BIT,
	@sensortype CHAR(1),
	@digitalsensortypeid SMALLINT=NULL,
	@sensorindex TINYINT,
	@isinverted BIT,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN

--	DECLARE	@VehicleSensorId INT,
--			@vid UNIQUEIDENTIFIER,
--			@description NVARCHAR(MAX),
--			@shortname NVARCHAR(MAX),
--			@colour NVARCHAR(MAX),
--			@enabled BIT,
--			@sensortype CHAR(1),
--			@digitalsensortypeid SMALLINT,
--			@sensorindex TINYINT,
--			@isinverted BIT,
--			@uid UNIQUEIDENTIFIER
--
--	SET	@VehicleSensorId = 33
--	SET	@vid = N'97F53C63-1B1D-4760-9DE9-2B09A740A513'
--	SET	@description = NULL
--	SET	@shortname = NULL
--	SET	@colour = NULL
--	SET	@enabled = 1
--	SET	@sensortype = 'D'
--	SET @digitalsensortypeid = 12
--	SET	@sensorindex = 1
--	SET	@isinverted = 0
--	SET	@uid = NULL

	DECLARE @sensorid SMALLINT,
			@creationcodeactive SMALLINT,
			@creationcodeinactive SMALLINT,
			@count TINYINT
			
	-- Identify the SensorId for the Sensor Type and Index provided
	SELECT @sensorid = SensorId, @creationcodeactive = CreationCodeIdActive, @creationcodeinactive = CreationCodeIdInactive
	FROM dbo.Sensor
	WHERE SensorType = @sensortype
	  AND SensorIndex = @sensorindex

	IF @VehicleSensorId IS NULL -- Add new sensor details
	BEGIN
		INSERT INTO dbo.VehicleSensor (VehicleIntId, SensorId, DigitalSensorTypeId, Description, ShortName, Colour, AnalogSensorScaleFactor, Enabled)
		SELECT VehicleIntId, @sensorid, @digitalsensortypeid, @description, @shortname, @colour, @scale, @enabled
		FROM dbo.Vehicle
		WHERE VehicleId = @vid
		
		IF @isinverted = 1  AND @creationcodeactive IS NOT NULL -- Create entries in VehicleCreationCode table
		BEGIN
			INSERT INTO dbo.VehicleCreationCode (VehicleCreationCodeId, VehicleId, CreationCodeId, CreationCodeHighIsOff)
			VALUES  (NEWID(), @vid, @creationcodeactive, 1)
			INSERT INTO dbo.VehicleCreationCode (VehicleCreationCodeId, VehicleId, CreationCodeId, CreationCodeHighIsOff)
			VALUES  (NEWID(), @vid, @creationcodeinactive, 1)
		END	
		  
	END ELSE -- Update existing sensor details
	BEGIN
		UPDATE dbo.VehicleSensor
		SET DigitalSensorTypeId = @digitalsensortypeid, Description = @description, ShortName = @shortname, Colour = @colour, AnalogSensorScaleFactor = @scale, Enabled = @enabled, LastOperation = GETDATE()
		FROM dbo.VehicleSensor vs
		INNER JOIN dbo.Vehicle v ON vs.VehicleIntId = v.VehicleIntId
		WHERE vs.VehicleSensorId = @VehicleSensorId
		
		-- Check to see if VehicleCreationCode needs updating
		IF @creationcodeactive IS NOT NULL -- Sensor Type uses CreationCodes
		BEGIN
			SELECT @count = COUNT(*) 
			FROM dbo.VehicleCreationCode
			WHERE VehicleId = @vid AND CreationCodeId IN (@creationcodeactive, @creationcodeinactive)
			
			IF @isinverted = 1 AND ISNULL(@count,0) = 0 -- Add new rows to VehicleCreationCode
			BEGIN
				INSERT INTO dbo.VehicleCreationCode (VehicleCreationCodeId, VehicleId, CreationCodeId, CreationCodeHighIsOff)
				VALUES  (NEWID(), @vid, @creationcodeactive, 1)
				INSERT INTO dbo.VehicleCreationCode (VehicleCreationCodeId, VehicleId, CreationCodeId, CreationCodeHighIsOff)
				VALUES  (NEWID(), @vid, @creationcodeinactive, 1)
			END 
			
			IF ISNULL(@isinverted,0) = 0 AND ISNULL(@count,0) > 0 -- Delete existing rows from VehicleCreationCode
			BEGIN
				DELETE FROM dbo.VehicleCreationCode
				WHERE VehicleId = @vid AND CreationCodeId IN (@creationcodeactive, @creationcodeinactive) 
			END 
		END -- of VehicleCreationCode update
	END -- of existing sensor update
END
GO
