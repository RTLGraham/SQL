SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_WriteHeartbeatTemp]
	@vintid INT,
	@ivhintid INT,
	@payload NVARCHAR(MAX),
	@hid BIGINT OUTPUT
AS

	SET NOCOUNT OFF

	DECLARE @htime CHAR(8),
			@hdate CHAR(10),
			@econospeed VARCHAR(4),
			@sdcard VARCHAR(5),
			@firmware VARCHAR(10),
			@ecospeed BIT,
			@sdc BIT,
			@hbdatetime DATETIME
			
	-- Parse the Heartbeat payload
	DECLARE @Data TABLE (Id INT, Field NVARCHAR(MAX))
	INSERT INTO @Data (Id, Field) SELECT id, Value FROM dbo.Split(@payload, ',')
	SELECT @htime = Field FROM @Data WHERE Id = 1
	SELECT @hdate = Field FROM @Data WHERE Id = 2
	SELECT @econospeed = Field FROM @Data WHERE Id = 3
	SELECT @sdcard = Field FROM @Data WHERE Id = 4
	SELECT @firmware = Field FROM @Data WHERE Id = 5

	-- Set the datetime
	SET @hbdatetime = CONVERT(DATETIME, @hdate + ' ' + @htime, 103)
	
	-- Format the parameters
	SET @ecospeed = CASE @econospeed
						WHEN 'EOFF' THEN 0
						WHEN 'EON' THEN 1
						ELSE 0
					END
	SET @sdc = CASE @sdcard
					WHEN 'SDOFF' THEN 0
					WHEN 'SDON' THEN 1
					ELSE 0
			   END

	-- Write Heartbeat 						 
	INSERT INTO dbo.HeartbeatTemp (VehicleIntId, IVHIntId, HeartbeatDateTime, Econospeed, SDCard, Firmware)
	VALUES  (@vintid, @ivhIntid, @hbdatetime, @ecospeed, @sdc, @firmware)
	
	SET @hid = SCOPE_IDENTITY()
	
	-- Insert/Update @hbdatetime, @ecospeed, @sdc, @firmware into the VehicleLatestStatusTemp table
	DECLARE @cnt INT
	SET @cnt = 0
	SELECT @cnt = COUNT(*) FROM dbo.VehicleLatestStatusTemp WHERE VehicleIntId = @vintid AND Archived IS NULL
	IF @cnt > 0
	BEGIN
		-- UPDATE
		UPDATE dbo.VehicleLatestStatusTemp
		SET EcospeedStatus = @ecospeed,
			SDCardStatus = @sdc,
			Firmware = @firmware,
			UnitTime = @hbdatetime
		WHERE VehicleIntId = @vintid
		
	END ELSE
	BEGIN
		-- INSERT
		INSERT INTO dbo.VehicleLatestStatusTemp
		        ( VehicleIntId ,
		          UnitTime ,
		          EcospeedStatus ,
		          SDCardStatus ,
		          Firmware ,
		          LogNumber
		        )
		VALUES  ( 
				  @vintid,
				  @hbdatetime,
				  @ecospeed,
				  @sdc,
				  @firmware,
				  NULL
		        )
	END


GO
