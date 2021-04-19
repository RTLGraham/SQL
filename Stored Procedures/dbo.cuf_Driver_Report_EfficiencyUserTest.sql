SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Driver_Report_EfficiencyUserTest]
(
	@dids varchar(max),
	@sdate datetime = NULL,
	@edate datetime = NULL,
	@uid uniqueidentifier 
)
AS
BEGIN
	--DECLARE @driverid uniqueidentifier,
	--		@depid int,
	--		@cid uniqueidentifier,
	--		@sdate datetime,
	--		@edate datetime,
	--		@aid uniqueidentifier,
	--		@aidstring varchar(2000),
	--		@uid uniqueidentifier 

	--SET @sdate = '2009-07-21 00:00'
	--SET @edate = '2009-07-21 23:59'

	EXEC dbo.proc_ReportEfficiencyDrivercore_Test
		@dids = @dids,
		@sdate = @sdate,
		@edate = @edate,
		@uid = @uid
	
	SELECT * FROM [dbo].[Driver] WHERE DriverId in (select value from dbo.[Split](@dids, ','))
END

GO
