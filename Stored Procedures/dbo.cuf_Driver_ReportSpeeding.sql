SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Driver_ReportSpeeding]
(
	@did NVARCHAR(MAX),
	@uid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME
)
AS
BEGIN
	--DECLARE @did NVARCHAR(max),
	--		@uid UNIQUEIDENTIFIER,
	--		@sdate DATETIME,
	--		@edate DATETIME
	--SET @did = N'DD0ED3A1-FA7A-4573-BACA-040DA9E75F63,883BBEFD-3402-4CF4-81E2-22170DE40A41,0594362C-8735-4711-9BD8-26316E6CC1BD,8F2224CE-C44B-44D1-B661-4CFE0337B903'
	--SET @uid = N'7BAEE9C3-1B0E-49FC-A98D-D5A2D6ADF8CA'
	--SET @sdate = '2011-08-01 00:00'
	--SET @edate = '2011-08-05 23:59'
	
	--EXECUTE dbo.[proc_ReportSpeedingVehicle] 
	--   @did
	--  ,@uid
	--  ,@sdate
	--  ,@edate
	--GO


	
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
			IsHigh BIT
		)
		SELECT * FROM @results
		RETURN
	END
	ELSE 
	BEGIN
		
		--EXECUTE dbo.[clr_GetSpeedingStreetsByDriver]  
		--	@driverIds = @did, 
		--	@startdate = @sdate, 
		--	@enddate = @edate,
		--	@userid = @uid
		
		EXECUTE dbo.[proc_ReportSpeedingDrivers] 
		   @did
		  ,@uid
		  ,@sdate
		  ,@edate
	END	
	
END

GO
