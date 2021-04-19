SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Driver_Report_Efficiency_ByVehicleConfigId]
(
	@dids varchar(max),
	@startDate datetime,
	@endDate datetime,
	@userId UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS
BEGIN
--DECLARE @driverId uniqueidentifier,
--		@startDate datetime,
--		@endDate datetime,
--		@userId uniqueidentifier;

--SET @driverId = N''
--SET @startDate = '2009-07-21'
--SET @endDate = '2009-07-25'

	--EXEC [proc_GetReportSafetyByDriver_Reporting]
	EXEC dbo.proc_ReportByVehicleConfigId
		@vids = NULL,
		@dids = @dids,
		@sdate = @startDate,
		@edate = @endDate,
		@uid = @userId,
		@rprtcfgid = @rprtcfgid
END



GO
