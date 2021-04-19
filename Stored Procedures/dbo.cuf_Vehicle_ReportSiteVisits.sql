SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_ReportSiteVisits]
	@sids NVARCHAR(MAX) = NULL,
	@vids NVARCHAR(MAX) = NULL,
	@sdate DATETIME = NULL,
	@edate DATETIME = NULL,
	@uid UNIQUEIDENTIFIER = NULL
AS
BEGIN
	EXECUTE dbo.[proc_ReportSiteVisits] @sids, @vids, @sdate, @edate, @uid
END
GO
