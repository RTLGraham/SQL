SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_ReportSpeedingIVH]
(
	@vid NVARCHAR(MAX),
	@uid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME
)
AS
BEGIN
	EXECUTE dbo.[proc_ReportSpeedingVehiclesIVH] 
		   @vid
		  ,@uid
		  ,@sdate
		  ,@edate
END

GO
