SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_StopsPaxCount]
(
	@uid UNIQUEIDENTIFIER,
	@vids NVARCHAR(MAX),
	@routes NVARCHAR(MAX),
	@sdate DATETIME,
	@edate DATETIME
)
AS

	--DECLARE	@vids NVARCHAR(MAX),
	--		@sdate DATETIME,
	--		@edate DATETIME,
	--		@uid UNIQUEIDENTIFIER;

	--SET		@vids = N''
	--SET		@sdate = '2014-05-31 23:59'
	--SET		@edate = '2014-04-01 00:00'
	--SET		@uid = N''

	EXEC	dbo.[proc_Report_StopsPaxCount]
			@vids = @vids,
			@routes = @routes,
			@sdate = @sdate,
			@edate = @edate,
			@uid = @uid

GO
