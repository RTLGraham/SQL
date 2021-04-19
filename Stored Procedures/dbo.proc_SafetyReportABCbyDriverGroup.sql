SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_SafetyReportABCbyDriverGroup]
(
	@sdate DATETIME,
	@edate DATETIME,
	@gids NVARCHAR(MAX),
	@dids NVARCHAR(MAX),
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS

	--DECLARE @sdate DATETIME,
	--	@edate DATETIME,
	--	@gids NVARCHAR(MAX),
	--	@dids NVARCHAR(MAX),
	--	@uid UNIQUEIDENTIFIER,
	--	@rprtcfgid UNIQUEIDENTIFIER
	--SET @gids = N'F44FB45E-164C-451D-85D5-2ED7ED3F7ABAN,BCD2D8EE-B5C5-46D6-AF71-EE9DB73EC7C0'
	--SET @dids = N'62BAF2A8-0F5A-457A-80EF-3F8CDF2EA58F,796C4341-1702-42C8-BA32-E1461E99177E'
	--SET @sdate = '2015-07-01 00:00'
	--SET @edate = '2015-08-28 23:59'
	--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
	--SET	@rprtcfgid = N'E671E529-196F-4C6A-83FE-5F51B1257862'

	-- Determine if multiple vehicle configurations are going to be used and fork between fair and standard version appropriately
	DECLARE @configcount INT

	SELECT @configcount = ISNULL(COUNT(DISTINCT vrc.ReportConfigurationId), 0)
	FROM dbo.Reporting r
	INNER JOIN dbo.Driver d ON d.DriverIntId = r.DriverIntId
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = r.VehicleIntId
	INNER JOIN dbo.VehicleReportConfiguration vrc ON vrc.VehicleId = v.VehicleId
	WHERE d.DriverId IN (SELECT Value FROM dbo.Split(@dids, ','))
	  AND r.Date BETWEEN @sdate AND @edate

	IF @configcount > 0 -- Use zero rather than one to ensure consistency when running with multiple vehicles
		EXECUTE dbo.proc_SafetyReportABCbyDriverGroup_Fair
				@sdate,
				@edate,
				@gids,
				@dids,
				@uid,
				@rprtcfgid
	ELSE	
		EXECUTE dbo.proc_SafetyReportABCbyDriverGroup_Standard
				@sdate,
				@edate,
				@gids,
				@dids,
				@uid,
				@rprtcfgid


GO
