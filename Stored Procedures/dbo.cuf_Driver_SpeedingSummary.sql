SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_SpeedingSummary]
          @uid      uniqueidentifier,
          @dids     nvarchar(MAX),
          @sdate    datetime,
          @edate    datetime
AS
          EXEC dbo.proc_DashboardReport_SpeedingSummaryByDriver @uid, @dids, @sdate, @edate;


GO
