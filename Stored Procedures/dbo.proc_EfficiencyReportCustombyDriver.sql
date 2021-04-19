SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[proc_EfficiencyReportCustombyDriver]
(
	@sdate DATETIME,
	@edate DATETIME,
	@dids NVARCHAR(MAX),
	@uid UNIQUEIDENTIFIER,
	@configid UNIQUEIDENTIFIER
)
AS

	--DECLARE @sdate DATETIME,
	--	@edate DATETIME,
	--	@dids NVARCHAR(MAX),
	--	@uid UNIQUEIDENTIFIER,
	--	@configid UNIQUEIDENTIFIER
	--SET @dids = N'e4a1d651-bd68-401c-a259-f264844fc1cc,a4c27118-f05e-44d8-87ae-5f4ddd62290c,cfc9903e-9b86-42d0-a7ef-16bf18e4af9d,f17ac3a2-e933-4ae5-8d48-d364f61f2801,aac52dec-cee9-44ed-bb95-2eff0cc83a30,edbb2098-0bfa-49e5-b5f6-c6334b740e08,a1bfa9d5-0fe9-4475-9b9a-ccd77c1816f4,6adde47c-06ce-4ad8-9439-b69a5207dd71,3c4bc202-69be-4ce1-bbbb-f07444d3334c,095d439f-d97c-48b1-922a-789c0f4d8ae9,928261cf-9381-46d8-9789-5130272641f2,796c4341-1702-42c8-ba32-e1461e99177e,18aba55d-ce2d-4c40-8b63-87eb04790b32,b85910c9-29c1-476b-97e8-bc039c3c0e65,cce39982-76e6-40a3-8870-8ff4beafb612,8de78a50-0523-4eb1-82c9-e708aba48277,c9283d0e-4de3-4abf-b04b-0da95003c367,2cd8a238-bf55-4b10-b241-fa985a426c56,92ee3a99-87bc-4d4a-af89-354004b2f8c9'
	--SET @sdate = '2016-04-01 00:00'
	--SET @edate = '2016-04-15 23:59'
	----SET @uid = N'3C65E267-ED53-4599-98C5-CBF5AFD85A66'
	--SET @uid = N'E3ACB89A-E2F7-4325-8F2A-C228FF9056BA'
	--SET @configid = N'e671e529-196f-4c6a-83fe-5f51b1257862'

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
		EXECUTE proc_EfficiencyReportCustombyDriver_Fair
				@sdate,
				@edate,
				@dids,
				@uid,
				@configid
	ELSE	
		EXECUTE proc_EfficiencyReportCustombyDriver_Standard
				@sdate,
				@edate,
				@dids,
				@uid,
				@configid
		





GO
