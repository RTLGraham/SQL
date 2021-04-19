SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_WriteLogDataTemp]
    @vintid INT,
    @ivhintid INT,
    @payload NVARCHAR(MAX),
	@lid BIGINT OUTPUT
AS 

	SET NOCOUNT OFF
	
    DECLARE @lognumber INT,
			@ldate CHAR(10),
			@ltime CHAR(8),
			@runtime INT,
			@deceltime INT,
			@stattime INT,
			@ecotime INT,
			@miles FLOAT,
			@movingfuel FLOAT,
			@statfuel FLOAT,
			@ldatetime DATETIME
	
	-- Parse the Log Data payload
	DECLARE @Data TABLE (Id INT, Field NVARCHAR(MAX))
	INSERT INTO @Data (Id, Field) SELECT id, Value FROM dbo.Split(@payload, ',')
	SELECT @lognumber = Field FROM @Data WHERE Id = 1
	SELECT @ldate = Field FROM @Data WHERE Id = 2
	SELECT @ltime = Field FROM @Data WHERE Id = 3
	SELECT @runtime = Field FROM @Data WHERE Id = 4
	SELECT @deceltime = Field FROM @Data WHERE Id = 5
	SELECT @stattime = Field FROM @Data WHERE Id = 6
	SELECT @ecotime = Field FROM @Data WHERE Id = 7
	SELECT @miles = Field FROM @Data WHERE Id = 8
	SELECT @movingfuel = Field FROM @Data WHERE Id = 9
	SELECT @statfuel = Field FROM @Data WHERE Id = 10
	
	/*Sick: Distance is in miles, fuel is in litres*/
	SET @miles = @miles * 1.609344
	
	-- Set the datetime
	SET @ldatetime = CONVERT(DATETIME, @ldate + ' ' + @ltime, 103)
			     
	INSERT INTO dbo.LogDataTemp
	        ( VehicleIntId,
	          IVHId,
	          LogNumber,
	          LogDateTime,
	          RunTime,
	          DecelTime,
	          StatTime,
	          EcoTime,
	          TotalDistance,
	          MovingFuel,
	          StatFuel
	        )
	VALUES  ( @vintid,
	          @ivhintid,
	          @lognumber,
	          @ldatetime,
	          @runtime,
	          @deceltime,
	          @stattime,
	          @ecotime,
	          @miles,
	          @movingfuel, 
	          @statfuel
	        )
	        
	SET @lid = SCOPE_IDENTITY()


	-- Insert/Update @lognumber, @ldatetime into the VehicleLatestStatusTemp table
	DECLARE @cnt INT
	SET @cnt = 0
	SELECT @cnt = COUNT(*) FROM dbo.VehicleLatestStatusTemp WHERE VehicleIntId = @vintid AND Archived IS NULL
	IF @cnt > 0
	BEGIN
		-- UPDATE
		UPDATE dbo.VehicleLatestStatusTemp
		SET LogNumber = @lognumber,
			UnitTime = @ldatetime
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
				  @ldatetime,
				  NULL,
				  NULL,
				  NULL,
				  @lognumber
		        )
	END
GO
