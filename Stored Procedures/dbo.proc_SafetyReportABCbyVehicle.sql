SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[proc_SafetyReportABCbyVehicle]
(
	@sdate DATETIME,
	@edate DATETIME,
	@vids NVARCHAR(MAX),
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS

	--DECLARE @sdate DATETIME,
	--	@edate DATETIME,
	--	@vids NVARCHAR(MAX),
	--	@uid UNIQUEIDENTIFIER,
	--	@rprtcfgid UNIQUEIDENTIFIER
	--SET @vids = N'a158f8a8-d73b-4eef-962b-670c1bab6696,a2a7640a-7cd1-48d3-8270-80a8f2c9fa63,3554137e-4695-46ac-a678-f6428e995b91,383fc529-05e2-4f17-abd5-c9e08895e29d,ea9340a7-ea1d-43f1-a213-e95b7be2225e,6cc1f03d-9ccb-47cb-8796-c641a5b951c3,bf808915-a86d-4eb8-9804-c64375223662,ab2e895d-cb6f-4bd9-8cf1-71e976e6f335,4dd73b7f-2fc4-4f06-b888-a4c4aa923c58,9264e0ad-e96d-4974-b0fd-1e50ddf18bdd,59dfb1e2-e0dc-4a80-b588-ac2af23a23d3,9bbd17d4-3be2-4e29-b550-509ab56ca92f,ac4a7f16-acaf-41e5-b7cb-57c1c3123c20'
	--SET @sdate = '2016-04-01 00:00'
	--SET @edate = '2016-04-15 23:59'
	--SET @uid = N'3c65e267-ed53-4599-98c5-cbf5afd85a66'
	--SET @rprtcfgid = N'e671e529-196f-4c6a-83fe-5f51b1257862'

	-- Determine if multiple vehicle configurations are going to be used and fork between fair and standard version appropriately
	DECLARE @configcount INT

	SELECT @configcount = ISNULL(COUNT(DISTINCT ReportConfigurationId), 0)
	FROM dbo.VehicleReportConfiguration
	WHERE VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))

	IF @configcount > 0 -- Use zero rather than one to ensure consistency when running with multiple vehicles
		EXECUTE dbo.proc_SafetyReportABCbyVehicle_Fair
				@sdate,
				@edate,
				@vids,
				@uid,
				@rprtcfgid
	ELSE	
		EXECUTE dbo.proc_SafetyReportABCbyVehicle_Standard
				@sdate,
				@edate,
				@vids,
				@uid,
				@rprtcfgid


GO
