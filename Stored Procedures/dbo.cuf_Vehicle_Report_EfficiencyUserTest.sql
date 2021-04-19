SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_EfficiencyUserTest]
(
	@vehicleids varchar(max),
	@sdate datetime = NULL,
	@edate datetime = NULL,
	@userid uniqueidentifier 
)
AS
BEGIN
	--DECLARE @vehicleid uniqueidentifier,
	--		@depid int,
	--		@cid uniqueidentifier,
	--		@sdate datetime,
	--		@edate datetime,
	--		@aid uniqueidentifier,
	--		@aidstring varchar(2000),
	--		@uid uniqueidentifier 

	--SET @vehicleId = N'F9931F36-8D99-4C1A-A730-7D60B4DAE00C'
	--SET @sdate = '2009-07-21 00:00'
	--SET @edate = '2009-07-21 23:59'

	EXEC dbo.[proc_ReportEfficiencyVehicleScore_Test]
		@vids = @vehicleIds,
		@sdate = @sdate,
		@edate = @edate,
		@uid = @userid
	
	SELECT * FROM [dbo].[Vehicle] WHERE VehicleId in (select value from dbo.[Split](@vehicleIds, ','))
END


GO
