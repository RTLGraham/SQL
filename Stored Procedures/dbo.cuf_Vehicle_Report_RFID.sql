SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_RFID]
(
	@vids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN
	--DECLARE	@vids varchar(max),
	--	@sdate datetime,
	--	@edate datetime,
	--	@uid UNIQUEIDENTIFIER

	--SET @vids = N'696C510A-557E-4FAD-899A-4EC17BB6C791'
	--SET @sdate = '2012-08-01 00:00'
	--SET @edate = '2012-08-28 23:59'
	--SET @uid = N'C9D8691F-4383-4CFA-A36D-3A6DF53136D8' 

	EXEC dbo.[proc_ReportRFID] 
	   @vids
	  ,@sdate
	  ,@edate
	  ,@uid
END


GO
