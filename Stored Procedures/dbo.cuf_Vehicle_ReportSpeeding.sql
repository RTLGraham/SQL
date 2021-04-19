SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_ReportSpeeding]
(
	@vid NVARCHAR(MAX),
	@uid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME
)
AS
BEGIN
	--DECLARE @vid NVARCHAR(max),
	--		@uid UNIQUEIDENTIFIER,
	--		@sdate DATETIME,
	--		@edate DATETIME
	--SET @vid = N'A6B1F69C-87D7-4444-81AD-E0EA50760BF4'
	--SET @uid = N'988D25DE-65E9-4FC5-8981-3D2B4EA0FEAB'
	--SET @sdate = '2018-01-01 00:00'
	--SET @edate = '2018-05-05 23:59'


	
	DECLARE @fmtonlyon bit
	SELECT @fmtonlyon = 0
	-- this will evaluate to true when FMTONLY is ON, because 'if' statements aren't actually evaluated.
	IF 1 = 0 SELECT @fmtonlyon = 1
	SET FMTONLY OFF
	
	
	IF @fmtonlyon = 1 
	BEGIN
		SET FMTONLY ON
		DECLARE @results TABLE
		(
			Registration VARCHAR(50),
			Speed INT,
			SpeedLimit INT,
			EventDateTime DATETIME,
			Lat FLOAT,
			SafeNameLong FLOAT,
            Heading INT,
			SpeedUnit VARCHAR(50),
			RevGeocode VARCHAR(250),
			DriverName NVARCHAR(MAX),
			IsHigh BIT,
			EventId BIGINT,
			IsDispute BIT
		)
		SELECT * FROM @results
		RETURN
	END
	ELSE 
	BEGIN
		--EXECUTE dbo.[clr_GetSpeedingStreets]  
		--	@vehicleIds = @vid, 
		--	@userid = @uid, 
		--	@startdate = @sdate, 
		--	@enddate = @edate

		EXECUTE dbo.[proc_ReportSpeedingVehicles] 
		   @vid
		  ,@uid
		  ,@sdate
		  ,@edate
	END	
END

GO
