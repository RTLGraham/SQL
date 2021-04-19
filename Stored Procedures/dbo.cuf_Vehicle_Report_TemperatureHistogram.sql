SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_TemperatureHistogram]
(
	@vids NVARCHAR(MAX),
	@gids NVARCHAR(MAX),
	@sdate DATETIME,
	@edate DATETIME,
	@uid UNIQUEIDENTIFIER,
	@sensorid TINYINT
)
AS
BEGIN

EXEC dbo.[proc_ReportTemperatureHistogram]
	@vids = @vids,
	@gids = @gids,
	@sdate = @sdate,
	@edate = @edate,
	@uid = @uid,
	@sensorid = @sensorid

END

GO
