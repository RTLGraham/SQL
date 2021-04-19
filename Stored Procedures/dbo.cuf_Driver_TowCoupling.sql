SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_TowCoupling]
(
	@dids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid uniqueidentifier,
	@rprtcfgid uniqueidentifier
)
AS
	EXECUTE dbo.[proc_ReportTowCoupling_ByDriver] 
	   @dids
	  ,@sdate
	  ,@edate
	  ,@uid
	  ,@rprtcfgid

GO
