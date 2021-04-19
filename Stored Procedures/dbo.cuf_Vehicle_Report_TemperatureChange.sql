SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_TemperatureChange]
(
	@vid UNIQUEIDENTIFIER,
	@gid UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER,
	@dio INT,
	@sdate DATETIME,
	@edate DATETIME
)
AS
BEGIN

	EXECUTE dbo.[proc_ReportTemperatureChange] 
	   @vid
	  ,@gid
	  ,@uid
	  ,@dio
	  ,@sdate
	  ,@edate

END


GO
