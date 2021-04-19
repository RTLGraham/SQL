SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_SpeedingSummary]
          @uid      uniqueidentifier,
          @vids     nvarchar(MAX),
          @sdate    datetime,
          @edate    datetime
AS
          EXEC dbo.proc_DashboardReport_SpeedingSummaryByVehicle @uid, @vids, @sdate, @edate;


GO
