SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ReportException]
	@vids NVARCHAR(MAX),
	@gids NVARCHAR(MAX) = NULL,
	@metricid INT,
	@extime DATETIME,
	@sdate DATETIME,
	@edate DATETIME,
	@flag BIT,
	@uid UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

--	DECLARE @vids NVARCHAR(MAX),
--			@gids NVARCHAR(MAX), -- NULL
--			@metricid INT,
--			@extime DATETIME,
--			@sdate DATETIME,
--			@edate DATETIME,
--			@flag BIT,
--			@uid UNIQUEIDENTIFIER
--
--	SET @vids = N'6CC1F03D-9CCB-47CB-8796-C641A5B951C3,2C38D238-E1A6-4E08-B419-345ACB40930F'	
--	SET @metricid = 2
--	SET @sdate = '2013-01-09 09:00'
--	SET @edate = '2013-01-09 12:00'
--	SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
			
	DECLARE @mode INT
	SET @mode = CASE @metricid
					WHEN 0 THEN 4
					WHEN 1 THEN	1
					WHEN 2 THEN 2
					WHEN 3 THEN 1
					WHEN 4 THEN 1
				END	
		
	SELECT v.Registration, dbo.FormatDriverNameByUser(d.DriverId, @uid), e.Lat, e.Long, e.EventDateTime--, e.CreationCodeId
	FROM dbo.Event e
	INNER JOIN dbo.Driver d ON e.DriverIntId = d.DriverIntId
	INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
	INNER JOIN dbo.VehicleModeCreationCode vmcc ON e.CreationCodeId = vmcc.CreationCodeId
	WHERE e.VehicleIntId IN (SELECT dbo.GetVehicleIntFromId(value) FROM dbo.Split(@vids, ','))
	  AND e.EventDateTime BETWEEN @sdate AND @edate
	  AND vmcc.VehicleModeId = @mode

END



GO
