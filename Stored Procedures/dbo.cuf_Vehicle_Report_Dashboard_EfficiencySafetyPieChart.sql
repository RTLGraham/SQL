SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_Dashboard_EfficiencySafetyPieChart]
(
	@groupid UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@bandCount INT
)
AS
BEGIN
	--DECLARE @groupid UNIQUEIDENTIFIER,
	--		@sdate datetime,
	--		@edate datetime,
	--		@uid UNIQUEIDENTIFIER,
	--		@bandCount INT

	--SET @sdate = '2011-01-01 00:00'
	--SET @edate = '2011-02-01 00:00'
	--SET @groupid = N'F9931F36-8D99-4C1A-A730-7D60B4DAE00C'	
	--SET @uid = 	'7BAEE9C3-1B0E-49FC-A98D-D5A2D6ADF8CA'
	--SET @bandCount = 5
	
	EXEC dbo.[proc_ReportDashboard_EfficiencySafetyPieChart_VehicleGroup] 
		@groupid, 
		@uid, 
		@sdate, 
		@edate,
		@bandCount
END



GO
