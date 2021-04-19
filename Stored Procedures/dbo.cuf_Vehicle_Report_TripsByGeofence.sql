SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_TripsByGeofence]
    (
      @vids NVARCHAR(MAX),
      @gids NVARCHAR(MAX),
      @sdate DATETIME,
      @edate DATETIME,
      @reportparameter1 INT,
      @idle INT,
      @uid UNIQUEIDENTIFIER,
      @maxidle INT = NULL
    )
AS
          EXEC dbo.[proc_ReportTripsByGeofence] @vids, @gids, @sdate, @edate, @reportparameter1, @idle, @uid, @maxidle;
GO
