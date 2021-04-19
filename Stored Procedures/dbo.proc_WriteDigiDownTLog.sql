SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_WriteDigiDownTLog] 
	@trackerid VARCHAR(50),
	@filename VARCHAR(50),
	@timestamp DATETIME,
	@uploadid INT,
	@success BIT,
	@status VARCHAR(20),
	@drivernumber VARCHAR(50) = NULL,
	@smartAnalID NVARCHAR(1024) = NULL,
    @smartAnalResponse NVARCHAR(MAX) = NULL
AS

--DECLARE	@trackerid VARCHAR(50),
--		@filename VARCHAR(50),
--		@timestamp DATETIME,
--		@uploadid INT,
--		@success BIT,
--		@status VARCHAR(20),
--		@drivernumber VARCHAR(50)

--SET @trackerid = '114900497'
--SET @filename  = 'F1900497_43782a00.vu'
--SET @timestamp = '2015-11-23 12:34:56'
--SET @uploadid  = 1000
--SET @success   = 1
--SET @status    = 'QUEUED'
--SET @drivernumber = 'DB131091620400'

DECLARE @vintid INT,
		@ivhintid INT,
		@dintid INT

SET @vintid = -1 -- initialise 
SET @dintid = -1

-- get ivh and vehicle details
SELECT @ivhintid = i.IVHIntId, @vintid = v.VehicleIntId
FROM IVH i
	INNER JOIN Vehicle v ON i.IVHId = v.IVHId
WHERE SerialNumber = @trackerid 
	AND i.Archived = 0 AND v.Archived = 0 AND (i.IsTag = 0 OR i.IsTag IS NULL)

-- get driver details if drivernumber is present
IF @drivernumber IS NOT NULL AND @drivernumber != ''
BEGIN
	SELECT TOP 1 @dintid = DriverIntId
	FROM dbo.Driver
	WHERE (Number = @drivernumber OR NumberAlternate = @drivernumber OR NumberAlternate2 = @drivernumber)
	  AND Archived = 0
END	
	
IF @vintid != -1
BEGIN
	INSERT INTO dbo.DigiDownTLog
			( VehicleIntId ,
			  IVHIntId ,
			  FileName ,
			  FileTimeStamp ,
			  FTAUploadId ,
			  Succeeded ,
			  Reason ,
			  UploadDateTime,
			  DriverIntId,
              SmartAnalID,
              SmartAnalResponse
			)
	VALUES  ( @vintid, -- VehicleIntId - int
			  @ivhintid , -- IVHIntId - int
			  @filename , -- FileName - varchar(50)
			  @timestamp , -- FileTimeStamp - datetime
			  @uploadid , -- FTAUploadId - int
			  @success , -- Succeeded - bit
			  @status , -- Reason - varchar(20)
			  GETDATE(),  -- UploadDateTime - datetime
			  CASE WHEN @dintid != -1 THEN @dintid ELSE NULL END,
			  @smartAnalID,
			  @smartAnalResponse
			)
END	
ELSE
BEGIN
	INSERT INTO dbo.DigiDownTLog
			( FileName ,
			  FileTimeStamp ,
			  FTAUploadId ,
			  Succeeded ,
			  Reason ,
			  UploadDateTime,
			  DriverIntId,
			  SmartAnalID,
			  SmartAnalResponse
			)
	VALUES  ( @filename , -- FileName - varchar(50)
			  @timestamp , -- FileTimeStamp - datetime
			  @uploadid , -- FTAUploadId - int
			  @success , -- Succeeded - bit
			  @status , -- Reason - varchar(20)
			  GETDATE(),  -- UploadDateTime - datetime
			  CASE WHEN @dintid != -1 THEN @dintid ELSE NULL END,
			  @smartAnalID,
			  @smartAnalResponse
			)
END	


GO
