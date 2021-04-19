SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_DataDispatcher]
	@path VARCHAR(MAX),
	@fName VARCHAR(MAX),
	@option SMALLINT,
	@parseType SMALLINT
AS

--DECLARE @fName VARCHAR(MAX),
--		@parseType SMALLINT,
--		@option SMALLINT,
--		@path VARCHAR(MAX)
--SET @option = 1
--SET @path = 'C:\pathname\'
--SET @fName = 'OP_1174_John Smith_2015-02-01 14:40_Hello there.zip'
--SET @parseType = 1
----SET @fName = 'OP1174Smith2015-02-01 14:40Hello.zip'
----SET @parseType = 2

------------------------------------------------------------------------
-- Options:                                                           --
--   1: Send command to cheetah to instruct file download             --
--   2: Log FTP request for file transfer to 3rd party                --
--   3: Send command to cheetah to instruct Rubicon file download     --
------------------------------------------------------------------------

DECLARE @Delimiter CHAR(1),
		@fNameNoEx VARCHAR(MAX),
		@IVHId UNIQUEIDENTIFIER

DECLARE @ParseData TABLE
(
	Sequence SMALLINT,
	Name VARCHAR(MAX),
	Value VARCHAR(MAX),
	DataType VARCHAR(15)
)

-- Determine if the filename is delimited or fixed width based on the settings for the parsetype
SELECT @Delimiter = Delimiter
FROM dbo.ParseType
WHERE ParseTypeId = @parseType

-- Check for an extension and remove if present prior to parsing the filename
IF SUBSTRING(@fName,LEN(@fName)-3,1) = '.' SET @fNameNoEx = LEFT(@fName,LEN(@fName)-4)
ELSE SET @fNameNoEx = @fName

-- Now parse the filename using the appropriate method to determine relevant data (e.g. TruckId)
-- Data is parsed into the temporary table @ParseData from which it can be selected later
IF @Delimiter IS NOT NULL
BEGIN
	INSERT INTO @ParseData (Sequence, Name, Value, DataType)
	SELECT d.Sequence, d.Name, p.Value, d.DataType
	FROM dbo.ParseDef d
	CROSS APPLY
	(	SELECT *
		FROM dbo.Split(@fNameNoEx, @Delimiter) p
		WHERE d.Sequence = p.Id AND d.ParseType = @parseType
	) p
END ELSE
BEGIN
	INSERT INTO @ParseData (Sequence, Name, Value, DataType)
	SELECT d.Sequence, d.Name, p.Value, d.DataType
	FROM dbo.ParseDef d
	CROSS APPLY
	(
		SELECT SUBSTRING(@fNameNoEx, p.Start, p.Len) AS Value
		FROM dbo.ParseDef p
		WHERE p.Sequence = d.Sequence AND p.ParseType = @parseType
	) p
	WHERE d.ParseType = @parseType
END

-- Now execute the commands required for the option selected
IF @option = 1 -- Send command to Cheetah to instruct file download
BEGIN
	-- Check that entry exists for the Truck Id
	SELECT	@IVHId = v.IVHId
	FROM @ParseData pd
	INNER JOIN dbo.Vehicle v ON pd.Value = v.FleetNumber AND pd.Name = 'TruckId'
	WHERE v.Archived = 0
	
	IF @IVHId IS NOT NULL -- Successfully found unit so send command and log activity
	BEGIN
		INSERT INTO dbo.VehicleCommand (IVHId, Command, ExpiryDate, LastOperation, Archived)
		SELECT	v.IVHId,
--				CAST('>STCXAT+FTPD=82.71.196.93,ss1,da59fwy,/' + @fName + ',' + @path + @fName AS BINARY(1024)),
--				CAST('>STCXAT+OPFD=88.98.53.100,Cheetah,dirsa_69,/J/FILEMAN/POUT/' + @fName + ',' + @path + @fName AS BINARY(1024)),
				CAST('>STCXAT+OPFD=82.71.196.93,Cheetah,dirsa_69,/J/FILEMAN/POUT/' + @fName + ',' + @path + @fName AS BINARY(1024)),
				DATEADD(dd, 1, GETUTCDATE()),
				GETDATE(),
				0
		FROM @ParseData pd
		INNER JOIN dbo.Vehicle v ON pd.Value = v.FleetNumber AND pd.Name = 'TruckId'
		WHERE v.Archived = 0	
			
		-- Log the activity
		INSERT INTO dbo.DataDispatchLog (DispatchType, FileName, Timestamp)
		VALUES  ('To Cheetah', @path + @fName, GETDATE())
	END ELSE -- Couuld not find vehicle so log error
	BEGIN
		INSERT INTO dbo.DataDispatchErrorLog (Component, Header, Message, Timestamp)
		VALUES  ( 'SQL Data Dispatcher',
		          'Invalid Truck Id',
		          'Could not find FleetNumber in Vehicle table for file ' + @fName,
		          GETDATE()
		        )
	END
END

IF @option = 2 -- No database action required. Just log the FTP request
BEGIN
	-- Log the activity
	INSERT INTO dbo.DataDispatchLog (DispatchType, FileName, Timestamp)
	VALUES  ('FTP', @path + @fName, GETDATE())
END

IF @option = 3 -- Send command to Cheetah to instruct Rubicon file download
BEGIN
	-- Check that entry exists for the Truck Id
	SELECT	@IVHId = v.IVHId
	FROM @ParseData pd
	INNER JOIN dbo.Rubicon_TrucksVehicles v ON CAST(pd.Value AS BIGINT) = v.TruckId AND pd.Name = 'TruckId'
	WHERE v.Archived = 0
	
	IF @IVHId IS NOT NULL -- Successfully found unit so send command and log activity
	BEGIN
		INSERT INTO dbo.VehicleCommand (IVHId, Command, ExpiryDate, LastOperation, Archived)
		SELECT	v.IVHId,
				CAST('>STCXAT+OPFD=82.71.196.93,Cheetah,dirsa_69,/J/FILEMAN/POUT/' + @fName + ',' + @path + @fName AS BINARY(1024)),
				DATEADD(dd, 1, GETUTCDATE()),
				GETDATE(),
				0
		FROM @ParseData pd
		INNER JOIN dbo.Rubicon_TrucksVehicles v ON CAST(pd.Value AS BIGINT) = v.TruckId AND pd.Name = 'TruckId'
		WHERE v.Archived = 0	
			
		-- Log the activity
		INSERT INTO dbo.DataDispatchLog (DispatchType, FileName, Timestamp)
		VALUES  ('To Cheetah', @path + @fName, GETDATE())
	END ELSE -- Couuld not find vehicle so log error
	BEGIN
		INSERT INTO dbo.DataDispatchErrorLog (Component, Header, Message, Timestamp)
		VALUES  ( 'SQL Data Dispatcher',
		          'Invalid Truck Id',
		          'Could not find FleetNumber in Vehicle table for file ' + @fName,
		          GETDATE()
		        )
	END
END

GO
