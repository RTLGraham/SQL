SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_EfficiencyReportCustombyDriverGroup]
(
	@sdate DATETIME,
	@edate DATETIME,
	@gids NVARCHAR(MAX),
	@dids NVARCHAR(MAX),
	@uid UNIQUEIDENTIFIER,
	@configid UNIQUEIDENTIFIER
)
AS

--DECLARE @sdate DATETIME,
--	@edate DATETIME,
--	@gids NVARCHAR(MAX),
--	@dids NVARCHAR(MAX),
--	@uid UNIQUEIDENTIFIER,
--	@configid UNIQUEIDENTIFIER
--SET @gids = N'5C3153C6-FA67-471B-8008-3122D35CFEED'
--SET @dids = N'1B5600D4-85AE-4A78-B071-2EE555EB3300,843EEAB8-EC94-4923-8327-402B09F64F1F,5E9679AC-1B6F-4700-97E8-53BB46B0BC01,0D572BAC-D832-4D53-A192-7F7C56E1D37B,98E7ECE2-6AA1-41D9-BAA9-8B9CAB5D5FD2,983AEB57-6600-42C3-BA24-8D307F5AD57F,BB3428A6-B8A5-4E7A-A081-99806369285F,071410D1-1B88-40E7-8D81-ADE51D9683E9,26C8A9B2-2EB9-49A1-8C8D-DFBA04C697C3,0071EDE5-3222-4A5F-A00C-EB679C17B6FC,51D84E06-84FB-451C-8A02-F86F0219C39A'
--SET @sdate = '2014-02-01 00:00'
--SET @edate = '2014-02-28 23:59'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET @configid = N'e8bf08bd-595d-4e40-98af-0b07e5242021'

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
		EXECUTE dbo.proc_EfficiencyReportCustombyDriverGroup_Fair
				@sdate,
				@edate,
				@gids,
				@dids,
				@uid,
				@configid
	ELSE	
		EXECUTE dbo.proc_EfficiencyReportCustombyDriverGroup_Standard
				@sdate,
				@edate,
				@gids,
				@dids,
				@uid,
				@configid



GO
