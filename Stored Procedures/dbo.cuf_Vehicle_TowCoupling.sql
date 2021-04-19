SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_TowCoupling]
(
	@vids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid uniqueidentifier,
	@rprtcfgid uniqueidentifier
)
AS
	EXECUTE dbo.[proc_ReportTowCoupling_ByVehicle] 
	   @vids
	  ,@sdate
	  ,@edate
	  ,@uid
	  ,@rprtcfgid

GO
