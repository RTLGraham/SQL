SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_FuelEmissions]
(
	@gids VARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER,
	@vids VARCHAR(MAX)= NULL
)
AS
BEGIN

	EXECUTE dbo.[proc_ReportFuelEmissions] 
	   @gids
	  ,@sdate
	  ,@edate
	  ,@uid
	  ,@rprtcfgid
	  ,@vids

END



GO
