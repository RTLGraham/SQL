SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_NCE_Temperature]
(
	@gid UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime,
	@sensorid SMALLINT,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN
	EXECUTE dbo.[proc_ReportNCE_Temperature] 
	   @gid
	  ,@sdate
	  ,@edate
	  ,@sensorid
	  ,@uid
END



GO
