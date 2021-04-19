SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportPerformance_Group]
(
	@gids varchar(max), 
	@gtypeid INT,
	@depid INT = NULL,
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
) 
AS

IF @gtypeid = 1
	EXEC proc_ReportPerformance_Group_Vehicle @gids, @sdate, @edate, @uid, @rprtcfgid
ELSE
	EXEC proc_ReportPerformance_Group_Driver @gids, @sdate, @edate, @uid, @rprtcfgid
	

GO
