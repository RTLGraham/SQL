SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_ExceptionSummary]
          @uid      uniqueidentifier,
          @vids     nvarchar(MAX),
          @count    int,
          @sdate    datetime,
          @edate    datetime
AS
          EXEC dbo.proc_DashboardReport_ExceptionSummary @uid, @vids, @count, @sdate, @edate;


GO
