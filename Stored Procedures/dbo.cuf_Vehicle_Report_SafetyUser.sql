SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_SafetyUser]
(
	@vehicleids varchar(max),
	@sdate datetime = NULL,
	@edate datetime = NULL,
	@userid uniqueidentifier
)
AS
BEGIN
--DECLARE @vehicleId uniqueidentifier,
--		@CustomerIntId int,
--		@customerId uniqueidentifier,
--		@startDate datetime,
--		@endDate datetime,
--		@userId uniqueidentifier;

--SET @startdate = '2009-07-21'
--SET @enddate = '2009-07-25'
--SET @vehicleId = N'F9931F36-8D99-4C1A-A730-7D60B4DAE00C'		

	EXEC dbo.[proc_ReportEfficiencyVehicleScore_RS]
		@vids = @vehicleids,
		@sdate = @sdate,
		@edate = @edate,
		@expanddates = 1,
		@uid = @userid
	
	SELECT * FROM dbo.[Vehicle] WHERE VehicleId in (select value from dbo.[Split](@vehicleids, ','))

END

GO
