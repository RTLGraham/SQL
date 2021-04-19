SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_Report_Combined_Linq]
(
	@dids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid uniqueidentifier,
	@rprtcfgid uniqueidentifier
)
AS
BEGIN

--DECLARE	@dids varchar(max),
--		@sdate datetime,
--		@edate datetime,
--		@uid UNIQUEIDENTIFIER,
--		@rprtcfgid UNIQUEIDENTIFIER

--SET	@dids = N'08f993da-981d-4692-9326-fadc82b93051'
--SET	@sdate = '2018-05-28 00:00'
--SET	@edate = '2018-07-01 23:59:59'
--SET	@uid = N'3db40c4a-7e79-4f41-8017-de6e12ec7a20'
--SET	@rprtcfgid = N'e671e529-196f-4c6a-83fe-5f51b1257862'

	EXECUTE dbo.[proc_Report_Combined_Linq]
	  @dids
	  ,@sdate
	  ,@edate
	  ,@uid
	  ,@rprtcfgid
	  

	
END

GO
