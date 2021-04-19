SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Driver_Report_SafetyUser]
(
	@vids varchar(max),
	@startDate datetime,
	@endDate datetime,
	@userId uniqueidentifier
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
	EXEC dbo.[proc_ReportEfficiencyDrivercore_RS]
		@vids = @vids,
		@depid = null,
		@sdate = @startDate,
		@edate = @endDate,
		@uid = @userId
END

GO
