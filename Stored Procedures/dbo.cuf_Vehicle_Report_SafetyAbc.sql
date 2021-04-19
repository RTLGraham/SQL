SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_SafetyAbc]
(
	@vids VARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
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

EXEC dbo.[proc_ReportByConfigID]
	@vids = @vids,
	@dids = NULL,
	@sdate = @sdate,
	@edate = @edate,
	@uid = @uid,
	@rprtcfgid = @rprtcfgid
END


GO
