SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Driver_Report_SafetyEfficiencyCombined]
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
	EXEC dbo.[proc_ReportEfficiency_Cubed]
		@vids = @vids,
		@sdate = @startDate,
		@edate = @endDate,
		@expanddates = 0,
		@uid = @userId
END

GO
