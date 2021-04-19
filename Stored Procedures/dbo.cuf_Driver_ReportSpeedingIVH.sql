SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_ReportSpeedingIVH]
(
	@did NVARCHAR(MAX),
	@uid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME
)
AS
BEGIN
	
	EXECUTE dbo.[proc_ReportSpeedingDriversIVH] 
		@did
		,@uid
		,@sdate
		,@edate
	
END

GO
