SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [dbo].[cuf_Driver_Report_FuelEmissions]
(
	@gids VARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER,
	@dids VARCHAR(MAX)= NULL
)
AS
BEGIN

	EXECUTE dbo.[proc_ReportFuelEmissions_Driver] 
	   @gids
	  ,@sdate
	  ,@edate
	  ,@uid
	  ,@rprtcfgid
	  ,@dids

END




GO
