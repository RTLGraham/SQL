SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******   Currently mixing up vehicle and driver groups   *********************************/

CREATE PROCEDURE [dbo].[proc_ReportPerformance_Fleet]
(
	@gtypeid INT,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
) 
AS

IF @gtypeid = 1
	EXEC proc_ReportPerformance_Fleet_Vehicle @uid, @rprtcfgid
ELSE
	EXEC proc_ReportPerformance_Fleet_Driver @uid, @rprtcfgid
	

GO
