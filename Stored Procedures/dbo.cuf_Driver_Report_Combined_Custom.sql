SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Driver_Report_Combined_Custom]
(
	@dids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid uniqueidentifier,
	@rprtcfgid uniqueidentifier
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

	EXECUTE dbo.[proc_Report_CombinedCustom]
	  @dids
	  ,@sdate
	  ,@edate
	  ,@uid
	  ,@rprtcfgid

END

GO
