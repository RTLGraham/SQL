SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_SafetyEfficiencyCombined]
(
	@vids VARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid uniqueidentifier
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

EXEC dbo.[proc_ReportEfficiency_Cubed]
	@vids = @vids,
	@sdate = @sdate,
	@edate = @edate,
	@expanddates = 0,
	@uid = @uid

	SELECT * FROM dbo.Vehicle WHERE Vehicle.VehicleId in (select value from dbo.[Split](@vids, ','))
END

GO
