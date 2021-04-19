SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_TAN_SendVehicleCommand] 
	@vid UNIQUEIDENTIFIER, @did UNIQUEIDENTIFIER, @command VARCHAR(255)
AS
BEGIN

	DECLARE @CommandString VARCHAR(MAX),
			@InvalidCommand BIT,
			@ExpiryDate DATETIME
			
	SET @InvalidCommand = 1 -- Initialise to Invalid Command
	
	-- Create initial command structure
	SELECT @CommandString = it.WriteCommandPrefix + c.CommandRoot + it.WriteCommandSuffix
	FROM dbo.Vehicle v
	INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
	INNER JOIN dbo.IVHType it ON i.IVHTypeId = it.IVHTypeId
	INNER JOIN dbo.CFG_Command c ON it.IVHTypeId = c.IVHTypeId
	WHERE v.VehicleId = @vid
	  AND c.CommandRoot = @command
	  
	-- Now add parameters according to type of command
	IF @command = 'RTLG'
	BEGIN -- Set Language Command -- Retrieve language for driver
		DECLARE @HardwareIndex SMALLINT
		SELECT @HardwareIndex = lc.HardwareIndex
		FROM dbo.Driver d
		INNER JOIN dbo.LanguageCulture lc ON d.LanguageCultureId = lc.LanguageCultureID
		WHERE DriverId = @did
		  AND d.Surname NOT IN ('No ID', 'UNKNOWN') -- Only send command for known drivers
		
		IF @HardwareIndex IS NOT NULL
		BEGIN
			SET @CommandString = @CommandString + CAST(@HardwareIndex AS CHAR(2))
			SET @InvalidCommand = 0
			SET @ExpiryDate = DATEADD(mi, 10, GETDATE())
		END
	END

	IF @command = 'NAME'
	BEGIN -- Return driver name command
		SELECT @CommandString = @CommandString + ISNULL(dbo.FormatDriverNameByUser(@did, NULL), 'UNKNOWN')
		SET @InvalidCommand = 0
		SET @ExpiryDate = DATEADD(mi, 10, GETDATE())
	END

	--Final check that the commandstring has been created properly (may be NULL if command not configured)
	IF @CommandString IS NULL SET @InvalidCommand = 1

	-- if the command is valid write an entry into VehicleCommand
	IF @InvalidCommand = 0
		INSERT INTO dbo.VehicleCommand
				( IVHId ,
				  Command ,
				  ExpiryDate
				)
		SELECT i.IVHId, CAST(@CommandString AS VARBINARY(MAX)), @ExpiryDate
		FROM dbo.Vehicle v
		INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
		WHERE v.VehicleId = @vid
		
	RETURN @InvalidCommand

END

GO
