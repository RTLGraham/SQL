SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_RouteDrilldown]
(
	@rids varchar(max), 
	@vids NVARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@groupby TINYINT
)
AS
	
	EXECUTE dbo.[proc_Report_RouteAnalysisDrillDown] 
	   @rids
	  ,@vids
	  ,@sdate
	  ,@edate
	  ,@uid
	  ,@groupby


GO
