SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_RouteDetail]
(
	@rids varchar(max), 
	@vids NVARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER
)
AS
	
	EXECUTE dbo.proc_Report_RouteDetail
	   @rids
	  ,@vids
	  ,@sdate
	  ,@edate
	  ,@uid



GO
