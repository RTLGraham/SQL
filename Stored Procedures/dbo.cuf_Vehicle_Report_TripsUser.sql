SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_TripsUser]
(
	@uid UNIQUEIDENTIFIER,
	@vid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@idle INT,
	@ignition bit = null
)
AS

--DECLARE	@vid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME,
--		@idle INT;

--SET		@vid = N'F9931F36-8D99-4C1A-A730-7D60B4DAE00C'
--SET		@sdate = '2009-07-21'
--SET		@edate = '2009-07-25'
--SET		@idle = 5

DECLARE @rep INT

IF @ignition IS NULL
	SET @rep = 2
ELSE
	SET @rep = 1

EXEC	dbo.[proc_GetReportTrips_Cached]
		@vid = @vid,
		@sdate = @sdate,
		@edate = @edate,
		@reportparameter1 = @rep,
		@idle = @idle,
		@uid = @uid

GO
