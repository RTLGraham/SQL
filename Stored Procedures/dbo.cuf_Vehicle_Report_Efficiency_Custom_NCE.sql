SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_Efficiency_Custom_NCE]
(
	@vids VARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid uniqueidentifier,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS
BEGIN

--DECLARE @vids VARCHAR(MAX),
--		@sdate datetime,
--		@edate datetime,
--		@uid uniqueidentifier,
--		@rprtcfgid UNIQUEIDENTIFIER
--
--SET @vids = N'02EA55B8-EB47-4A27-8BAB-18682C6DA0F2,2243BCEB-95B2-478D-9F0E-BEF4E8420032,3F4862C3-195E-4137-91D7-7F79704FCC6B,FBC7F345-1D2B-47DE-8A58-8B56BDCFBEAC'
--SET @sdate = '2012-10-01 00:00'
--SET @edate = '2012-10-31 23:59'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET @rprtcfgid = N'618F8EFB-09D0-4A88-9172-723A615F6ACF'

EXEC dbo.[proc_ReportNCEByConfigID]
	@vids = @vids,
	@dids = NULL,
	@sdate = @sdate,
	@edate = @edate,
	@uid = @uid,
	@rprtcfgid = @rprtcfgid

	SELECT * FROM [dbo].[Vehicle] WHERE VehicleId in (select value from dbo.[Split](@vids, ','))
END


GO
