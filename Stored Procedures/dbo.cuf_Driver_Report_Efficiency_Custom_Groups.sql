SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Driver_Report_Efficiency_Custom_Groups]
(
	@gids VARCHAR(MAX),
	@dids VARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid uniqueidentifier,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS
BEGIN	
	EXEC dbo.[proc_ReportByConfigId_DriverGroups] 
	   @gids
	  ,@dids
	  ,@sdate
	  ,@edate
	  ,@uid
	  ,@rprtcfgid
END



GO
