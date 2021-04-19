SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_ReportCharacteristicsMatrix]
    (
		@vid UNIQUEIDENTIFIER,
		@uid UNIQUEIDENTIFIER,
		@sdate DATETIME,
		@edate DATETIME
    )
AS 

EXEC dbo.[proc_ReportCharacteristicsMatrix] 
	@vid = @vid,
	@uid = @uid,
	@sdate = @sdate,
	@edate = @edate


GO
